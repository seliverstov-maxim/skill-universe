#!/bin/sh
set -eu

manifest="$HOME/.skill-universe/manifest.json"
if [ "$1" = all ]; then
    aliases=$(jq -r '.skills | to_entries | unique_by([.value.url, .value.branch]) | .[].key' "$manifest")
else
    aliases="$1"
fi

printf '%s\n' "$aliases" | while IFS= read -r alias; do
    [ -n "$alias" ] || continue
    url=$(jq -er --arg alias "$alias" '.skills[$alias].url' "$manifest")
    branch=$(jq -er --arg alias "$alias" '.skills[$alias].branch' "$manifest")
    checkout_id=$(printf '%s\n%s\n' "$url" "$branch" | git hash-object --stdin)
    checkout="$HOME/.skill-universe/repos/$checkout_id"

    git -C "$checkout" pull --ff-only "$url" "$branch"
    commit=$(git -C "$checkout" rev-parse HEAD)
    jq --arg url "$url" --arg branch "$branch" --arg commit "$commit" \
        '(.skills[] | select(.url == $url and .branch == $branch).commit) = $commit' \
        "$manifest" > "$manifest.tmp"
    mv "$manifest.tmp" "$manifest"
    jq -r --arg url "$url" --arg branch "$branch" \
        '.skills | to_entries[] | select(.value.url == $url and .value.branch == $branch) | "Updated: \(.key)"' "$manifest"
done
