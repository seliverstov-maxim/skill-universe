#!/bin/sh
set -eu

repo_url="$1"
shift
branch=""
skill=""
rule=""
alias=""

for argument in "$@"; do
    case "$argument" in
        --branch=*) branch=${argument#--branch=} ;;
        --skill=*) skill=${argument#--skill=} ;;
        --rule=*) rule=${argument#--rule=} ;;
        --alias=*) alias=${argument#--alias=} ;;
        *) printf 'Unknown argument: %s\n' "$argument" >&2; exit 1 ;;
    esac
done

if [ -n "$skill" ] && [ -n "$rule" ]; then
    printf '%s\n' '--skill and --rule are mutually exclusive' >&2
    exit 1
fi
if [ -n "$alias" ] && [ -z "$skill$rule" ]; then
    printf '%s\n' '--alias requires --skill or --rule' >&2
    exit 1
fi

manifest="$HOME/.skill-universe/manifest.json"
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

for source in "$checkout"/skills/* "$checkout"/rules/*.md; do
    name=${source##*/}
    case "$source" in
        "$checkout"/skills/*)
            [ -f "$source/SKILL.md" ] || continue
            [ -z "$rule" ] || continue
            [ -z "$skill" ] || [ "$name" = "$skill" ] || continue
            kind=skills; directory_key=directory; suffix=""
            ;;
        "$checkout"/rules/*)
            [ -f "$source" ] || continue
            name=${name%.md}
            [ -z "$skill" ] || continue
            [ -z "$rule" ] || [ "$name" = "$rule" ] || continue
            kind=rules; directory_key=rules_directory; suffix=.md
            ;;
    esac
    selected_alias=${alias:-$name}
    if jq -e --arg alias "$selected_alias" '(.skills + (.rules // {})) | has($alias)' "$manifest" >/dev/null; then
        printf 'Alias already installed: %s\n' "$selected_alias" >&2
        exit 1
    fi

    if [ "$kind" = rules ]; then
        jq '.rules //= {} | .harnesses |= with_entries(
            .value.rules_directory //= (if .key == "codex" then "~/.codex/rules" else "~/.claude/rules" end)
        )' "$manifest" > "$manifest.tmp"
        mv "$manifest.tmp" "$manifest"
    fi
    jq -r --arg key "$directory_key" '.harnesses[][$key]' "$manifest" | while IFS= read -r directory; do
        case "$directory" in '~/'*) directory="$HOME/${directory#\~/}" ;; esac
        mkdir -p "$directory"
        ln -s "$source" "$directory/$selected_alias$suffix"
        printf 'Installed: %s/%s%s\n' "$directory" "$selected_alias" "$suffix"
    done
    if [ "$kind" = rules ]; then
        sh "$(dirname "$0")/codex-rules.sh" add
    fi

    jq --arg kind "$kind" --arg alias "$selected_alias" --arg url "$repo_url" --arg branch "$branch" \
        --arg path "${source#"$checkout"/}" --arg commit "$commit" \
        '.[$kind][$alias] = {url: $url, branch: $branch, path: $path, commit: $commit}' \
        "$manifest" > "$manifest.tmp"
    mv "$manifest.tmp" "$manifest"
done
