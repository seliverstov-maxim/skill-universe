# Skill Universe

A small Unix CLI for installing and updating skills from Git repositories in Codex and Claude.

## Why

- A simple distribution tool you can read and review in full.
- No telemetry, rankings, external catalogs, or background network requests.
- Plain Git for fetching skills and updating the tool itself.
- One checkout for installation and local skill development through symlinks.

## Installation

Dependencies: a Unix shell, Git, and `jq`. Target platforms for the PoC are macOS and Linux.

Run:

```sh
curl -fsSL https://seliverstov-maxim.github.io/skill-universe/install.sh | sh
```

The installer clones the tool into `~/.skill-universe/tool/` and creates a command symlink in `~/.local/bin/`. Installer contents:

```sh
#!/bin/sh
set -eu

git clone "https://github.com/seliverstov-maxim/skill-universe.git" "$HOME/.skill-universe/tool"
chmod +x "$HOME/.skill-universe/tool/skill-universe"
mkdir -p "$HOME/.local/bin"
ln -s "$HOME/.skill-universe/tool/skill-universe" "$HOME/.local/bin/skill-universe"

printf 'Installed: %s/.local/bin/skill-universe\n' "$HOME"
printf 'Add to your shell profile: export PATH="$HOME/.local/bin:$PATH"\n'
```

Check that the command is available:

```sh
skill-universe --version
```

`init` sets the self-update source to `https://github.com/seliverstov-maxim/skill-universe.git`, branch `main`. No manual setup is needed for `upgrade`.

## Usage

Configure your chosen harnesses:

```sh
skill-universe init --harness=codex,claude
```

Install all skills from a repository, or select a skill, branch, and alias:

```sh
skill-universe install <repo-url>
skill-universe install <repo-url> --branch=<branch> --skill=<skill-name> --alias=<alias>
```

The source repository must contain `skills/<skill-name>/SKILL.md`. Without flags, all skills from the default branch are installed, using directory names as aliases.

Manage installed skills:

```sh
skill-universe list
skill-universe rename <alias> <new-alias>
skill-universe update <alias>
skill-universe update all
skill-universe remove <alias>
```

When skills share a checkout, updating one affects all skills linked to it. Local changes are allowed; if Git cannot fast-forward, you resolve the conflict.

Update the tool and view help:

```sh
skill-universe upgrade
skill-universe --version
skill-universe --help
```

The manifest lives at `~/.skill-universe/manifest.json`; clones live in `~/.skill-universe/repos/`. Harness directories and the Git source for `upgrade` are configurable in the manifest.
