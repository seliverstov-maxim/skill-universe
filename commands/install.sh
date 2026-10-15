#!/bin/sh
set -eu
. "$(dirname "$0")/common.sh"

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

[ -z "$alias" ] || name_ok "$alias"
[ -z "$skill" ] || name_ok "$skill"
[ -z "$rule" ] || name_ok "$rule"
if [ -z "$branch" ]; then
    remote_head=$(git ls-remote --symref -- "$repo_url" HEAD)
    branch=$(printf '%s\n' "$remote_head" | awk '$1 == "ref:" {sub("^refs/heads/", "", $2); print $2; exit}')
fi

checkout_id=$(printf '%s\n%s\n' "$repo_url" "$branch" | git hash-object --stdin)
checkout="$state/repos/$checkout_id"
if [ ! -d "$checkout" ]; then
    mkdir -p "$state/repos"
    git clone --branch "$branch" -- "$repo_url" "$checkout"
fi
commit=$(git -C "$checkout" rev-parse HEAD)
tree_ok "$checkout" "$commit"
for parent in "$checkout/skills" "$checkout/rules"; do
    if [ -e "$parent" ] || [ -L "$parent" ]; then
        source_ok "$parent"
    fi
done

matched=no
for source in "$checkout"/skills/* "$checkout"/skills/.[!.]* "$checkout"/skills/..?* \
    "$checkout"/rules/*.md "$checkout"/rules/.[!.]*.md "$checkout"/rules/..?*.md; do
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
    matched=yes
    selected_alias=${alias:-$name}
    name_ok "$selected_alias"
    source_ok "$source"
    if jq -e --arg alias "$selected_alias" '(.skills + (.rules // {})) | has($alias)' "$manifest" >/dev/null; then
        printf 'Alias already installed: %s\n' "$selected_alias" >&2
        exit 1
    fi

    if [ "$kind" = rules ]; then
        jq '.rules //= {} | .harnesses |= with_entries(
            .value.rules_directory //= (if .key == "codex" then "~/.codex/rules" else "~/.claude/rules" end)
        )' "$manifest" > "$work/manifest"
        mv "$work/manifest" "$manifest"
    fi
    directories
    while IFS= read -r directory; do
        expand_directory
        destination="$directory/$selected_alias$suffix"
        empty_destination "$destination"
        remember "$destination"
    done < "$work/directories"
    while IFS= read -r directory; do
        expand_directory
        mkdir -p "$directory"
        ln -s "$source" "$directory/$selected_alias$suffix"
        printf 'Installed: %s/%s%s\n' "$directory" "$selected_alias" "$suffix"
    done < "$work/directories"
    if [ "$kind" = rules ]; then
        remember "$codex_agents"
        sh "$(dirname "$0")/codex-rules.sh" add "$work"
    fi

    jq --arg kind "$kind" --arg alias "$selected_alias" --arg url "$repo_url" --arg branch "$branch" \
        --arg path "${source#"$checkout"/}" --arg commit "$commit" \
        '.[$kind][$alias] = {url: $url, branch: $branch, path: $path, commit: $commit}' \
        "$manifest" > "$work/manifest"
    mv "$work/manifest" "$manifest"
done

if [ -n "$skill$rule" ] && [ "$matched" = no ]; then
    fail "Requested skill or rule was not found: ${skill:-$rule}"
fi
