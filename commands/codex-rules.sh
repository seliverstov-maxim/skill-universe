#!/bin/sh
set -eu
manifest="$HOME/.skill-universe/manifest.json"
work="$2"
jq -e '.harnesses | has("codex")' "$manifest" >/dev/null || exit 0
file="$HOME/.codex/AGENTS.md"
[ ! -L "$file" ] || { printf 'AGENTS.md must not be a symlink\n' >&2; exit 1; }
if [ -e "$file" ]; then
    [ -f "$file" ] || exit 1
    awk '
        /^<!-- skill-universe:rules:start -->$/ { if (seen++ || inside) exit 1; inside=1 }
        /^<!-- skill-universe:rules:end -->$/ { if (!inside) exit 1; inside=0 }
        END { if (inside) exit 1 }
    ' "$file" || { printf 'Malformed skill-universe block; AGENTS.md left unchanged\n' >&2; exit 1; }
fi
if [ "$1" = add ]; then
    if [ -f "$file" ] && grep -Fqx '<!-- skill-universe:rules:start -->' "$file"; then exit 0; fi
    directory=$(jq -r '.harnesses.codex.rules_directory' "$manifest")
    if [ -f "$file" ]; then cat "$file" > "$work/agents"; else : > "$work/agents"; fi
    # shellcheck disable=SC2016 # Backticks delimit a Markdown path; they are not shell commands.
    printf '\n<!-- skill-universe:rules:start -->\nRead and follow all Markdown files in `%s`.\n<!-- skill-universe:rules:end -->\n' "$directory" >> "$work/agents"
else
    [ -f "$file" ] || exit 0
    sed '/^<!-- skill-universe:rules:start -->$/,/^<!-- skill-universe:rules:end -->$/d' "$file" > "$work/agents"
fi
mkdir -p "$HOME/.codex"
# Stage beside the destination so replacement does not truncate the original.
staged=$(mktemp "$HOME/.codex/.skill-universe.XXXXXX")
trap 'rm -f -- "$staged"' 0
if [ -f "$file" ]; then cp -p "$file" "$staged"; fi
cat "$work/agents" > "$staged"
mv -f "$staged" "$file"
