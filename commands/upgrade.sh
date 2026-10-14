#!/bin/sh
set -eu

url=$(jq -er '.upgrade.url' "$HOME/.skill-universe/manifest.json")
branch=$(jq -er '.upgrade.branch' "$HOME/.skill-universe/manifest.json")
git -C "$HOME/.skill-universe/tool" pull --ff-only "$url" "$branch"
printf 'Upgraded skill-universe\n'
