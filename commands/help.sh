#!/bin/sh
set -eu

cat <<'EOF'
skill-universe init --harness=codex,claude
skill-universe install <repo-url> [--branch=<branch>] [--skill=<skill-name>|--rule=<rule-name>] [--alias=<alias>]
skill-universe list
skill-universe rename <alias> <new-alias>
skill-universe update <alias>|all
skill-universe remove <alias>
skill-universe upgrade
skill-universe --version
skill-universe --help
EOF
