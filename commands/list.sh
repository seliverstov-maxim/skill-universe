#!/bin/sh
set -eu

jq -r '.harnesses | to_entries[] | "\(.key): \(.value.directory)"' "$HOME/.skill-universe/manifest.json"
printf 'ALIAS\tURL\tBRANCH\tPATH\n'
jq -r '.skills | to_entries[] | [.key, .value.url, .value.branch, .value.path] | @tsv' "$HOME/.skill-universe/manifest.json"
