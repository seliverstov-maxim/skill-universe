#!/bin/sh
set -eu

git clone "https://github.com/seliverstov-maxim/skill-universe.git" "$HOME/.skill-universe/tool"
chmod +x "$HOME/.skill-universe/tool/skill-universe"
mkdir -p "$HOME/.local/bin"
ln -s "$HOME/.skill-universe/tool/skill-universe" "$HOME/.local/bin/skill-universe"

printf 'Installed: %s/.local/bin/skill-universe\n' "$HOME"
printf 'Add to your shell profile: export PATH="$HOME/.local/bin:$PATH"\n'
