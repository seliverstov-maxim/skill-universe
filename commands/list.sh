#!/bin/sh
set -eu
. "$(dirname "$0")/paths.sh"

jq -r '.harnesses | to_entries[] | "\(.key): \(.value.directory) rules: \(.value.rules_directory // "not configured")"' "$state/manifest.json"
printf 'TYPE\tALIAS\tURL\tBRANCH\tPATH\n'
jq -r 'to_entries[] | select(.key == "skills" or .key == "rules") | .key as $kind |
    .value | to_entries[] | [$kind, .key, .value.url, .value.branch, .value.path] | @tsv' "$state/manifest.json"
