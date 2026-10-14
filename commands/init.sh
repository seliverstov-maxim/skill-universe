#!/bin/sh
set -eu

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

manifest=$(jq -n --arg harnesses "${1#--harness=}" '
    {
        version: 1,
        harnesses: ($harnesses | split(",") | map(
            if . == "codex" then
                {key: ., value: {directory: "~/.agents/skills"}}
            elif . == "claude" then
                {key: ., value: {directory: "~/.claude/skills"}}
            else
                error("Unknown harness: " + .)
            end
        ) | from_entries),
        upgrade: {url: null, branch: null},
        skills: {}
    }
')

mkdir -p "$HOME/.skill-universe"
(set -C; printf '%s\n' "$manifest" > "$HOME/.skill-universe/manifest.json")
printf 'Created: %s/.skill-universe/manifest.json\n' "$HOME"
