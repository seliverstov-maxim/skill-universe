#!/bin/sh
set -eu

repo_url="$1"
shift
branch=""
skill=""
alias=""

for argument in "$@"; do
    case "$argument" in
        --branch=*) branch=${argument#--branch=} ;;
        --skill=*) skill=${argument#--skill=} ;;
        --alias=*) alias=${argument#--alias=} ;;
        *) printf 'Unknown argument: %s\n' "$argument" >&2; exit 1 ;;
    esac
done

if [ -n "$alias" ] && [ -z "$skill" ]; then
    printf '%s\n' '--alias requires --skill' >&2
    exit 1
fi

manifest="$HOME/.skill-universe/manifest.json"
directories=$(jq -r '.harnesses[].directory' "$manifest")

if [ -z "$branch" ]; then
    remote_head=$(git ls-remote --symref -- "$repo_url" HEAD)
    branch=$(printf '%s\n' "$remote_head" | awk '$1 == "ref:" {sub("^refs/heads/", "", $2); print $2; exit}')
fi

checkout_id=$(printf '%s\n%s\n' "$repo_url" "$branch" | git hash-object --stdin)
checkout="$HOME/.skill-universe/repos/$checkout_id"
if [ ! -d "$checkout" ]; then
    mkdir -p "$HOME/.skill-universe/repos"
    git clone --branch "$branch" -- "$repo_url" "$checkout"
fi
commit=$(git -C "$checkout" rev-parse HEAD)

for source in "$checkout"/skills/*; do
    [ -f "$source/SKILL.md" ] || continue
    name=${source##*/}
    if [ -n "$skill" ] && [ "$name" != "$skill" ]; then
        continue
    fi
    selected_alias=${alias:-$name}
    if jq -e --arg alias "$selected_alias" '.skills | has($alias)' "$manifest" >/dev/null; then
        printf 'Alias already installed: %s\n' "$selected_alias" >&2
        exit 1
    fi

    printf '%s\n' "$directories" | while IFS= read -r directory; do
        case "$directory" in '~/'*) directory="$HOME/${directory#\~/}" ;; esac
        mkdir -p "$directory"
        ln -s "$source" "$directory/$selected_alias"
        printf 'Installed: %s/%s\n' "$directory" "$selected_alias"
    done

    jq --arg alias "$selected_alias" --arg url "$repo_url" --arg branch "$branch" \
        --arg path "skills/$name" --arg commit "$commit" \
        '.skills[$alias] = {url: $url, branch: $branch, path: $path, commit: $commit}' \
        "$manifest" > "$manifest.tmp"
    mv "$manifest.tmp" "$manifest"
done
