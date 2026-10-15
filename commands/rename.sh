#!/bin/sh
set -eu

alias="$1"
new_alias="$2"
manifest="$HOME/.skill-universe/manifest.json"
kind=skills; directory_key=directory; suffix=""
if jq -e --arg alias "$alias" '(.rules // {}) | has($alias)' "$manifest" >/dev/null; then
    kind=rules; directory_key=rules_directory; suffix=.md
fi

if jq -e --arg alias "$new_alias" '(.skills + (.rules // {})) | has($alias)' "$manifest" >/dev/null; then
    printf 'Alias already installed: %s\n' "$new_alias" >&2
    exit 1
fi

jq -r --arg key "$directory_key" '.harnesses[][$key]' "$manifest" | while IFS= read -r directory; do
    case "$directory" in '~/'*) directory="$HOME/${directory#\~/}" ;; esac
    mv "$directory/$alias$suffix" "$directory/$new_alias$suffix"
done

jq --arg kind "$kind" --arg alias "$alias" --arg new "$new_alias" \
    '.[$kind][$new] = .[$kind][$alias] | del(.[$kind][$alias])' "$manifest" > "$manifest.tmp"
mv "$manifest.tmp" "$manifest"
printf 'Renamed: %s -> %s\n' "$alias" "$new_alias"
