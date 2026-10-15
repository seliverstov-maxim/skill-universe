#!/bin/sh
set -eu

jq -r '.harnesses | to_entries[] | "\(.key): \(.value.directory) rules: \(.value.rules_directory // "not configured")"' "$HOME/.skill-universe/manifest.json"
printf 'TYPE\tALIAS\tURL\tBRANCH\tPATH\n'
jq -r 'to_entries[] | select(.key == "skills" or .key == "rules") | .key as $kind |
    .value | to_entries[] | [$kind, .key, .value.url, .value.branch, .value.path] | @tsv' "$HOME/.skill-universe/manifest.json"
