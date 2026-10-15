#!/bin/sh
set -eu
. "$(dirname "$0")/common.sh"

manifest="$HOME/.skill-universe/manifest.json"
if [ "$1" = all ]; then
    aliases=$(jq -r '(.skills + (.rules // {})) | to_entries | unique_by([.value.url, .value.branch]) | .[].key' "$manifest")
else
    aliases="$1"
fi

printf '%s\n' "$aliases" > "$work/aliases"
while IFS= read -r alias; do
    [ -n "$alias" ] || continue
    url=$(jq -er --arg alias "$alias" '(.skills + (.rules // {}))[$alias].url' "$manifest")
    branch=$(jq -er --arg alias "$alias" '(.skills + (.rules // {}))[$alias].branch' "$manifest")
    checkout_id=$(printf '%s\n%s\n' "$url" "$branch" | git hash-object --stdin)
    checkout="$HOME/.skill-universe/repos/$checkout_id"

    git -C "$checkout" fetch -- "$url" "$branch"
    candidate=$(git -C "$checkout" rev-parse FETCH_HEAD)
    tree_ok "$checkout" "$candidate"
    for parent in "$checkout/skills" "$checkout/rules"; do
        [ ! -e "$parent" ] && [ ! -L "$parent" ] || source_ok "$parent"
    done
    printf 'Update checkout: %s\nCandidate: %s\n' "$checkout" "$candidate" > "$work/git-pending"
    if ! git -C "$checkout" merge --ff-only --no-overwrite-ignore --no-autostash "$candidate"; then
        exit 1
    fi
    commit=$(git -C "$checkout" rev-parse HEAD)
    jq --arg url "$url" --arg branch "$branch" --arg commit "$commit" \
        '(.skills[], .rules[]? | select(.url == $url and .branch == $branch).commit) = $commit' \
        "$manifest" > "$work/manifest"
    mv "$work/manifest" "$manifest"
    checkpoint_manifest
    rm "$work/git-pending"
    jq -r --arg url "$url" --arg branch "$branch" \
        '(.skills + (.rules // {})) | to_entries[] | select(.value.url == $url and .value.branch == $branch) | "Updated: \(.key)"' "$manifest"
done < "$work/aliases"
