#!/bin/sh
# Shared defaults. The standalone installers embed this file; see scripts/generate-installer.sh.
# shellcheck disable=SC2034 # Values are consumed by sourcing commands and the installer body.
SKILL_UNIVERSE_HOME=${SKILL_UNIVERSE_HOME:-"$HOME/.skill-universe"}
SKILL_UNIVERSE_BIN_DIR=${SKILL_UNIVERSE_BIN_DIR:-"$HOME/.local/bin"}
SU_CODEX_HOME=${SU_CODEX_HOME:-"$HOME/.codex"}
SU_CLAUDE_HOME=${SU_CLAUDE_HOME:-"$HOME/.claude"}
SU_REPO_URL=${SU_REPO_URL:-"https://github.com/seliverstov-maxim/skill-universe.git"}
tool_branch=main
codex_skills_directory="$HOME/.agents/skills"
codex_rules_directory="$SU_CODEX_HOME/rules"
claude_skills_directory="$SU_CLAUDE_HOME/skills"
claude_rules_directory="$SU_CLAUDE_HOME/rules"
