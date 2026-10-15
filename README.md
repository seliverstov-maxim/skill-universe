# Skill Universe

A small Unix CLI for installing and updating skills and rules from Git repositories in Codex and Claude.

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

Install all skills and rules from a repository, or select one item, a branch, and an alias:

```sh
skill-universe install <repo-url>
skill-universe install <repo-url> --branch=<branch> --skill=<skill-name> --alias=<alias>
skill-universe install <repo-url> --rule=<rule-name> --alias=<alias>
```

Without filters, all skills and rules from the default branch are installed. Rule aliases default to filenames without `.md`; skill aliases default to directory names. Aliases are unique across both types. `--skill` and `--rule` are mutually exclusive; `--alias` requires one of them.

Rules are linked into `~/.codex/rules/` and `~/.claude/rules/` for your configured harnesses. For Codex, the first rule adds an instruction to read the rules directory in `~/.codex/AGENTS.md`, between `<!-- skill-universe:rules:start -->` and `<!-- skill-universe:rules:end -->`. Removing the last rule removes only that block, preserving your other instructions. Claude loads its user rules directory directly.

Manage installed skills and rules:

```sh
skill-universe list
skill-universe rename <alias> <new-alias>
skill-universe update <alias>
skill-universe update all
skill-universe remove <alias>
```

When skills and rules share a checkout, updating one affects all items linked to it. Local changes are allowed; if Git cannot fast-forward, you resolve the conflict.

Update the tool and view help:

```sh
skill-universe upgrade
skill-universe --version
skill-universe --help
```

The manifest lives at `~/.skill-universe/manifest.json`; clones live in `~/.skill-universe/repos/`. Harness skill directories (`directory`), rule directories (`rules_directory`), and the Git source for `upgrade` are configurable in the manifest. Existing manifests remain supported; installing the first rule adds the new settings.

## Repository structure

A repository can contain skills, rules, or both:

```text
repository/
|-- skills/
|   |-- skill-name/
|   |   |-- SKILL.md
|   |   |-- references/
|   |   `-- scripts/
|   `-- another-skill/
|       `-- SKILL.md
`-- rules/
    |-- code-style.md
    `-- testing.md
```

- **Skills:** each skill must have `skills/<skill-name>/SKILL.md`. Supporting files and directories are optional; the entire skill directory is linked into the harness.
- **Rules:** each rule is a plain Markdown file at `rules/<rule-name>.md`. No frontmatter is required; file contents are preserved.
- Both `skills/` and `rules/` are optional. Only immediate skill directories and immediate `.md` rule files are discovered. A root-level `SKILL.md`, nested rules, and other rule file extensions are ignored.
- `--skill=<skill-name>` selects a directory name; `--rule=<rule-name>` selects a filename without `.md`.

## Security verification

See the [current security review](docs/security/report.md) for the reviewed commit, open findings, methodology, and reproducible checks. This is a Codex-assisted review of a specific revision, not a claim that all versions or third-party skills and rules are safe.
