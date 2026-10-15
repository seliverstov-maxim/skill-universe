#!/bin/sh
# Prepare disposable Git fixtures inside the verification container. No scenarios run here.
set -eu
[ -d /source/verification/fixtures ] && [ -d /work ] || exit 1
if [ -e /work/author ] || [ -e /work/state ]; then
    printf 'Use a fresh verification container.\n' >&2; exit 1
fi
mkdir -p /work/author /work/tool-author /work/state /work/codex
cp -R /source/verification/fixtures/. /work/author/
git init -b main /work/author
git -C /work/author config user.name Verification
git -C /work/author config user.email verification@example.invalid
git -C /work/author add .
git -C /work/author commit -m 'Initial skill and rule fixtures'
git clone --bare /work/author /work/remote.git
cp -R /source/. /work/tool-author/
git init -b main /work/tool-author
git -C /work/tool-author config user.name Verification
git -C /work/tool-author config user.email verification@example.invalid
git -C /work/tool-author add .
git -C /work/tool-author commit -m 'Verification tool source'
git clone --bare /work/tool-author /work/tool-upstream.git
git clone /work/tool-upstream.git /work/state/tool
printf 'Personal instruction sentinel\n' > /work/codex/AGENTS.md
printf 'Fixtures ready. Tool: /work/state/tool/skill-universe\n'
