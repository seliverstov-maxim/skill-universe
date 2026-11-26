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
    --arg codex_skills "$codex_skills_directory" \
    --arg codex_rules "$codex_rules_directory" \
    --arg claude_skills "$claude_skills_directory" \
    --arg claude_rules "$claude_rules_directory" \
    --arg tool_url "$SU_REPO_URL" --arg tool_branch "$tool_branch" '
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
        upgrade: {url: $tool_url, branch: $tool_branch},
        skills: {},
        rules: {}
    }
')

printf '%s\n' "$initial_manifest" | jq -e '
    [.harnesses[] | .directory, .rules_directory] |
    all(.[]; startswith("/") and (contains("\n") | not))
' >/dev/null || fail 'Harness homes must be absolute paths without newlines'

mkdir -p "$state"
(set -C; printf '%s\n' "$initial_manifest" > "$state/manifest.json")

if printf '%s\n' "$initial_manifest" | jq -e '.harnesses | has("codex")' >/dev/null; then
    . "$(dirname "$0")/init-codex.sh"
fi
printf 'Created: %s/manifest.json\n' "$state"
