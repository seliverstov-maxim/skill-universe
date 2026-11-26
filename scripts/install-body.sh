#!/bin/sh
# Embedded after env.sh by generate-installer.sh.
# shellcheck disable=SC2154 # Shared values come from the embedded environment module.
state=$SKILL_UNIVERSE_HOME
bin=$SKILL_UNIVERSE_BIN_DIR
for directory in "$state" "$bin"; do
    case "$directory" in /*) ;; *) printf 'Expected an absolute path: %s\n' "$directory" >&2; exit 1 ;; esac
done
for destination in "$state/tool" "$bin/skill-universe"; do
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        printf 'Destination already exists: %s\n' "$destination" >&2
        exit 1
    fi
done

git clone --branch "$tool_branch" -- "$SU_REPO_URL" "$state/tool"
chmod +x "$state/tool/skill-universe"
mkdir -p "$bin"
ln -s "$state/tool/skill-universe" "$bin/skill-universe"
printf 'Installed: %s/skill-universe\n' "$bin"
printf 'Add this directory to your PATH: %s\n' "$bin"
