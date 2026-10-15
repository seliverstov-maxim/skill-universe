#!/bin/sh
set -eu
. "$(dirname "$0")/common.sh"

alias="$1"
new_alias="$2"
select_entry "$alias"
name_ok "$new_alias"

if jq -e --arg alias "$new_alias" '(.skills + (.rules // {})) | has($alias)' "$manifest" >/dev/null; then
    printf 'Alias already installed: %s\n' "$new_alias" >&2
    exit 1
fi

directories
while IFS= read -r directory; do
    expand_directory
    managed_link "$directory/$alias$suffix"
    empty_destination "$directory/$new_alias$suffix"
    remember "$directory/$new_alias$suffix"
    remember "$directory/$alias$suffix"
done < "$work/directories"
while IFS= read -r directory; do
    expand_directory
    mv -n "$directory/$alias$suffix" "$directory/$new_alias$suffix"
    [ ! -L "$directory/$alias$suffix" ] || fail "Rename did not move the source"
done < "$work/directories"

jq --arg kind "$kind" --arg alias "$alias" --arg new "$new_alias" \
    '.[$kind][$new] = .[$kind][$alias] | del(.[$kind][$alias])' "$manifest" > "$work/manifest"
mv "$work/manifest" "$manifest"
printf 'Renamed: %s -> %s\n' "$alias" "$new_alias"
