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

initial_manifest=$(jq -n --arg harnesses "${1#--harness=}" \
    --arg codex_skills "${SKILL_UNIVERSE_CODEX_SKILLS_DIR:-~/.agents/skills}" \
    --arg codex_rules "${SKILL_UNIVERSE_CODEX_RULES_DIR:-~/.codex/rules}" \
    --arg claude_skills "${SKILL_UNIVERSE_CLAUDE_SKILLS_DIR:-~/.claude/skills}" \
    --arg claude_rules "${SKILL_UNIVERSE_CLAUDE_RULES_DIR:-~/.claude/rules}" '
    {
        version: 1,
        harnesses: ($harnesses | split(",") | map(
            if . == "codex" then
                {key: ., value: {directory: $codex_skills, rules_directory: $codex_rules}}
            elif . == "claude" then
                {key: ., value: {directory: $claude_skills, rules_directory: $claude_rules}}
            else
                error("Unknown harness: " + .)
            end
        ) | from_entries),
        upgrade: {url: "https://github.com/seliverstov-maxim/skill-universe.git", branch: "main"},
        skills: {},
        rules: {}
    }
')

mkdir -p "$state"
(set -C; printf '%s\n' "$initial_manifest" > "$state/manifest.json")
printf 'Created: %s/manifest.json\n' "$state"
