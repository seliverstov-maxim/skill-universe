#!/bin/sh
set -eu
. "$(dirname "$0")/common.sh"

url=$(jq -er '.upgrade.url' "$manifest")
branch=$(jq -er '.upgrade.branch' "$manifest")
checkout="$state/tool"
git -C "$checkout" fetch -- "$url" "$branch"
candidate=$(git -C "$checkout" rev-parse FETCH_HEAD)
printf 'Upgrade tool checkout: %s\nCandidate: %s\n' "$checkout" "$candidate" > "$work/git-pending"
if ! git -C "$checkout" merge --ff-only --no-overwrite-ignore --no-autostash "$candidate"; then
    exit 1
fi
rm "$work/git-pending"
printf 'Upgraded skill-universe\n'
