#!/bin/sh
# shellcheck disable=SC2154 # Sourced by init; paths and work come from env.sh/common.sh.
# Sourced by init after the manifest is created; common.sh rolls both files back on error.
case "$SU_CODEX_HOME" in /*) ;; *) fail 'SU_CODEX_HOME must be an absolute path' ;; esac
case "$codex_rules_directory" in *'`'*|*'
'*) fail 'Backticks and newlines in the Codex rules path are not supported' ;; esac
[ ! -s "$SU_CODEX_HOME/AGENTS.override.md" ] || fail 'AGENTS.override.md takes precedence; connect the rules there manually'
codex_agents_file="$SU_CODEX_HOME/AGENTS.md"
[ ! -L "$codex_agents_file" ] || fail "Instruction file must not be a symlink: $codex_agents_file"
{
    printf '<!-- skill-universe:rules:start -->\n'
    printf '%s\n' "Before starting a task, read and follow all Markdown files under \`$codex_rules_directory\`, including subdirectories, if the directory exists."
    printf '<!-- skill-universe:rules:end -->\n'
} > "$work/rules-block"
if [ -f "$codex_agents_file" ]; then
    awk '
        $0 == "<!-- skill-universe:rules:start -->" {
            if (active || seen) exit 1
            active = 1; seen = 1; print; next
        }
        $0 == "<!-- skill-universe:rules:end -->" {
            if (!active) exit 1
            active = 0; print; next
        }
        active { print }
        END { if (active) exit 1 }
    ' "$codex_agents_file" > "$work/existing-block" || fail 'Malformed skill-universe rules block'
    if [ -s "$work/existing-block" ]; then
        cmp -s "$work/existing-block" "$work/rules-block" || fail 'Existing skill-universe block uses different rules; update it manually'
        printf 'Connected Codex rules: %s\n' "$codex_agents_file"
        return 0
    fi
fi
remember "$codex_agents_file"
mkdir -p "$SU_CODEX_HOME"
if [ -s "$codex_agents_file" ]; then printf '\n\n' >> "$codex_agents_file"; fi
cat "$work/rules-block" >> "$codex_agents_file"
printf 'Connected Codex rules: %s\n' "$codex_agents_file"
