#!/bin/sh
set -eu

manifest="$HOME/.skill-universe/manifest.json"
jq -e '.harnesses | has("codex")' "$manifest" >/dev/null || exit 0
file="$HOME/.codex/AGENTS.md"
start='<!-- skill-universe:rules:start -->'
end='<!-- skill-universe:rules:end -->'

if [ "$1" = add ]; then
    directory=$(jq -r '.harnesses.codex.rules_directory' "$manifest")
    mkdir -p "$HOME/.codex"
    touch "$file"
    if ! grep -Fqx -- "$start" "$file"; then
        printf '\n%s\nRead and follow all Markdown files in `%s`.\n%s\n' "$start" "$directory" "$end" >> "$file"
    fi
else
    sed '/^<!-- skill-universe:rules:start -->$/,/^<!-- skill-universe:rules:end -->$/d' "$file" > "$file.tmp"
    cat "$file.tmp" > "$file"
    rm "$file.tmp"
fi
