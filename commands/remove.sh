#!/bin/sh
set -eu

alias="$1"
manifest="$HOME/.skill-universe/manifest.json"
kind=skills; directory_key=directory; suffix=""
if jq -e --arg alias "$alias" '(.rules // {}) | has($alias)' "$manifest" >/dev/null; then
    kind=rules; directory_key=rules_directory; suffix=.md
fi

jq -r --arg key "$directory_key" '.harnesses[][$key]' "$manifest" | while IFS= read -r directory; do
    case "$directory" in '~/'*) directory="$HOME/${directory#\~/}" ;; esac
    rm "$directory/$alias$suffix"
done

jq --arg kind "$kind" --arg alias "$alias" 'del(.[$kind][$alias])' "$manifest" > "$manifest.tmp"
mv "$manifest.tmp" "$manifest"
if [ "$kind" = rules ] && jq -e '.rules | length == 0' "$manifest" >/dev/null; then
    sh "$(dirname "$0")/codex-rules.sh" remove
fi
printf 'Removed: %s\n' "$alias"
