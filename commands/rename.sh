#!/bin/sh
set -eu

alias="$1"
new_alias="$2"
manifest="$HOME/.skill-universe/manifest.json"

if jq -e --arg alias "$new_alias" '.skills | has($alias)' "$manifest" >/dev/null; then
    printf 'Alias already installed: %s\n' "$new_alias" >&2
    exit 1
fi

jq -r '.harnesses[].directory' "$manifest" | while IFS= read -r directory; do
    case "$directory" in '~/'*) directory="$HOME/${directory#\~/}" ;; esac
    mv "$directory/$alias" "$directory/$new_alias"
done

jq --arg alias "$alias" --arg new "$new_alias" \
    '.skills[$new] = .skills[$alias] | del(.skills[$alias])' "$manifest" > "$manifest.tmp"
mv "$manifest.tmp" "$manifest"
printf 'Renamed: %s -> %s\n' "$alias" "$new_alias"
