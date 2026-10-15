#!/bin/sh
# User-controlled locations; defaults remain unchanged.
state=${SKILL_UNIVERSE_HOME:-"$HOME/.skill-universe"}
codex_agents=${SKILL_UNIVERSE_CODEX_AGENTS_FILE:-"$HOME/.codex/AGENTS.md"}
for location in "$state" "$codex_agents"; do
    case "$location" in
        /*) ;;
        *) printf 'Expected an absolute path: %s\n' "$location" >&2; exit 1 ;;
    esac
done
