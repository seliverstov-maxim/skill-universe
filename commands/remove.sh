#!/bin/sh
set -eu

alias="$1"
manifest="$HOME/.skill-universe/manifest.json"

jq -r '.harnesses[].directory' "$manifest" | while IFS= read -r directory; do
    case "$directory" in '~/'*) directory="$HOME/${directory#\~/}" ;; esac
    rm "$directory/$alias"
done

jq --arg alias "$alias" 'del(.skills[$alias])' "$manifest" > "$manifest.tmp"
mv "$manifest.tmp" "$manifest"
printf 'Removed: %s\n' "$alias"
