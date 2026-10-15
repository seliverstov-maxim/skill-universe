# Skill Universe

A small Unix CLI for installing and updating skills and rules from Git repositories in Codex and Claude.

[![SU-SEC-1](docs/security/security-badge.svg)](https://seliverstov-maxim.github.io/skill-universe/security/report.html?method=SU-SEC-1)
[![SU-DECL-1](docs/security/declared-behavior-badge.svg)](https://seliverstov-maxim.github.io/skill-universe/security/report.html?method=SU-DECL-1)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/seliverstov-maxim/skill-universe/badge)](https://scorecard.dev/viewer/?uri=github.com/seliverstov-maxim/skill-universe)
[![CodeQL](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/codeql.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/codeql.yml)
[![ShellCheck](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/shellcheck.yml)
[![Gitleaks](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/gitleaks.yml)
[![zizmor](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/zizmor.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/zizmor.yml)
[![ClamAV](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/clamav.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/clamav.yml)

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

state=${SKILL_UNIVERSE_HOME:-"$HOME/.skill-universe"}
bin=${SKILL_UNIVERSE_BIN_DIR:-"$HOME/.local/bin"}
for directory in "$state" "$bin"; do
    case "$directory" in /*) ;; *) printf 'Expected an absolute path: %s\n' "$directory" >&2; exit 1 ;; esac
done
for destination in "$state/tool" "$bin/skill-universe"; do
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        printf 'Destination already exists: %s\n' "$destination" >&2
        exit 1
    fi
done

git clone "https://github.com/seliverstov-maxim/skill-universe.git" "$state/tool"
chmod +x "$state/tool/skill-universe"
mkdir -p "$bin"
ln -s "$state/tool/skill-universe" "$bin/skill-universe"
printf 'Installed: %s/skill-universe\n' "$bin"
printf 'Add this directory to your PATH: %s\n' "$bin"
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

Without filters, all skills and rules from the default branch are installed. Rule aliases default to filenames without `.md`; skill aliases default to directory names. Aliases are unique across both types. Skill names, rule names, and aliases may use ASCII letters, digits, `.`, `_`, and `-`; `.` and `..` are rejected. `--skill` and `--rule` are mutually exclusive; `--alias` requires one of them.

Rules are linked into `~/.codex/rules/` and `~/.claude/rules/` for your configured harnesses. For Codex, the first rule adds an instruction to read the rules directory in `~/.codex/AGENTS.md`, between `<!-- skill-universe:rules:start -->` and `<!-- skill-universe:rules:end -->`. Removing the last rule removes only that block, preserving your other instructions. Claude loads its user rules directory directly.

Manage installed skills and rules:

```sh
skill-universe list
skill-universe rename <alias> <new-alias>
skill-universe update <alias>
skill-universe update all
skill-universe remove <alias>
```

When skills and rules share a checkout, updating one affects all items linked to it. Local changes are allowed; updates use a fast-forward merge with automatic stashing disabled, refuse to overwrite ignored local files, and never reset the checkout. A failed or interrupted Git merge leaves recovery information as described below.

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
- Symbolic links anywhere under `skills/` or `rules/` are rejected, including links inside skill resources and links used as the top-level directories. Updates validate the incoming Git tree before applying it.
- `--skill=<skill-name>` selects a directory name; `--rule=<rule-name>` selects a filename without `.md`.

## File safety and recovery

Install and rename reject occupied destinations, including directories and dangling links. Remove and rename require a registered alias and its original installation symlink; a file or link you substituted is left alone. A malformed managed block or a symlink at `~/.codex/AGENTS.md` causes an error.

Commands that change state share a lock at `~/.skill-universe/lock/`. Links, the manifest, and AGENTS.md have backups in a private `~/.skill-universe/transaction.*` directory. Ordinary errors and handled signals trigger rollback of file changes. Newly created empty directories and cached clones can remain.

Git changes are not automatically reset. If a merge/pull fails or is interrupted, the command retains its lock and transaction directory for inspection, even for an ordinary Git conflict. `update all` commits progress separately for each checkout; earlier successful updates remain applied.

After forced termination, power loss, a failed Git operation, or failed rollback:

1. Confirm that no Skill Universe or related Git operation is still running. Do not remove an active command's lock.
2. Inspect the retained transaction directory. Each `entry.*` contains `path`, an optional `original` backup, and `ready` when the backup is complete. `git-pending`, when present, identifies the Git operation that needs inspection. Entries without `ready` are incomplete backups and must not be used for restoration.
3. For interrupted link operations, reconcile recorded paths with the backups and manifest. For a Git operation, inspect its checkout and local changes before deciding whether to finish or undo it. Align all manifest entries sharing that URL and branch with the resulting checkout HEAD. Do not blindly reset a development checkout or restore an older manifest over a completed update.
4. Once files and state agree, remove the recovered transaction directory and the empty lock directory. Commands can then run again.

This provides rollback and recoverable state, not an atomic transaction across Git, multiple filesystems, or power failure. Only install repositories whose instructions you trust; the tool does not sandbox skills or rules.

## Configurable locations

| Environment variable | Purpose |
| --- | --- |
| `SKILL_UNIVERSE_HOME` | State, manifest, repository cache and tool checkout; default `~/.skill-universe`. |
| `SKILL_UNIVERSE_BIN_DIR` | Installer command directory; default `~/.local/bin`. |
| `SKILL_UNIVERSE_CODEX_AGENTS_FILE` | Managed Codex instruction file; default `~/.codex/AGENTS.md`. |
| `SKILL_UNIVERSE_CODEX_SKILLS_DIR` / `SKILL_UNIVERSE_CODEX_RULES_DIR` | Codex paths stored by `init`. |
| `SKILL_UNIVERSE_CLAUDE_SKILLS_DIR` / `SKILL_UNIVERSE_CLAUDE_RULES_DIR` | Claude paths stored by `init`. |

State, installer and AGENTS.md overrides must be absolute paths. Harness paths may be absolute or start with `~/`; their environment overrides apply when creating a manifest. For an existing manifest, edit its `directory` and `rules_directory` values. Keep the state and AGENTS.md overrides consistent across commands. These settings do not isolate code execution: use the [verification environment](verification/README.md) for untrusted execution.
