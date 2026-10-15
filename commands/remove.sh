#!/bin/sh
set -eu
. "$(dirname "$0")/common.sh"

alias="$1"
select_entry "$alias"

directories
while IFS= read -r directory; do
    expand_directory
    managed_link "$directory/$alias$suffix"
    remember "$directory/$alias$suffix"
done < "$work/directories"
while IFS= read -r directory; do
    expand_directory
    rm -- "$directory/$alias$suffix"
done < "$work/directories"

jq --arg kind "$kind" --arg alias "$alias" 'del(.[$kind][$alias])' "$manifest" > "$work/manifest"
mv "$work/manifest" "$manifest"
if [ "$kind" = rules ] && jq -e '.rules | length == 0' "$manifest" >/dev/null; then
    remember "$codex_agents"
    sh "$(dirname "$0")/codex-rules.sh" remove "$work"
fi
printf 'Removed: %s\n' "$alias"
