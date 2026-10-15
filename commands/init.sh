#!/bin/sh
set -eu
. "$(dirname "$0")/common.sh"

if [ "$#" -ne 1 ]; then
    printf 'Usage: skill-universe init --harness=codex,claude\n' >&2
    exit 1
fi

case "$1" in
    --harness=?*) ;;
    *)
        printf 'Usage: skill-universe init --harness=codex,claude\n' >&2
        exit 1
        ;;
esac

initial_manifest=$(jq -n --arg harnesses "${1#--harness=}" '
    {
        version: 1,
        harnesses: ($harnesses | split(",") | map(
            if . == "codex" then
                {key: ., value: {directory: "~/.agents/skills", rules_directory: "~/.codex/rules"}}
            elif . == "claude" then
                {key: ., value: {directory: "~/.claude/skills", rules_directory: "~/.claude/rules"}}
            else
                error("Unknown harness: " + .)
            end
        ) | from_entries),
        upgrade: {url: "https://github.com/seliverstov-maxim/skill-universe.git", branch: "main"},
        skills: {},
        rules: {}
    }
')

mkdir -p "$HOME/.skill-universe"
(set -C; printf '%s\n' "$initial_manifest" > "$HOME/.skill-universe/manifest.json")
printf 'Created: %s/.skill-universe/manifest.json\n' "$HOME"
