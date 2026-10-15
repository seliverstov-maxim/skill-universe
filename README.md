# Skill Universe

A Unix CLI for installing and updating skills and rules from Git repositories for Codex and Claude. No telemetry or central catalog.

Release: **[v2.0.00](https://github.com/seliverstov-maxim/skill-universe/tree/v2.0.00)**. Incompatible with version 1; start with a fresh manifest using `init`.

[![SU-SEC-1](docs/security/security-badge.svg)](https://seliverstov-maxim.github.io/skill-universe/security/report.html?method=SU-SEC-1)
[![SU-DECL-1](docs/security/declared-behavior-badge.svg)](https://seliverstov-maxim.github.io/skill-universe/security/report.html?method=SU-DECL-1)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/seliverstov-maxim/skill-universe/badge)](https://scorecard.dev/viewer/?uri=github.com/seliverstov-maxim/skill-universe)
[![CodeQL](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/codeql.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/codeql.yml)
[![ShellCheck](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/shellcheck.yml)
[![Gitleaks](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/gitleaks.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/gitleaks.yml)
[![zizmor](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/zizmor.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/zizmor.yml)
[![ClamAV](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/clamav.yml/badge.svg)](https://github.com/seliverstov-maxim/skill-universe/actions/workflows/clamav.yml)

## Installation

For macOS and Linux. Requires a Unix shell, Git, and `jq`.

```sh
curl -fsSL https://seliverstov-maxim.github.io/skill-universe/install.sh | sh
```

Clones into `~/.skill-universe/tool/` and links the command in `~/.local/bin/`. The installer prints PATH instructions. Its full contents:

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

```sh
skill-universe --version
```

## Usage

Choose Codex, Claude, or both:

```sh
skill-universe init --harness=codex,claude
```

For Codex rules, follow the manual configuration instructions printed by `init`. Claude loads its user rules directory directly.

Install a repository, or select a skill or rule:

```sh
skill-universe install <repo-url>
skill-universe install <repo-url> --branch=<branch> --skill=<skill-name> --alias=<alias>
skill-universe install <repo-url> --rule=<rule-name> --alias=<alias>
```

Without selectors, installs all skills and rules from the default branch. Aliases default to skill directory names or rule filenames without `.md` and must be unique across both types. Use `--alias` to resolve duplicates.

Names and aliases accept ASCII letters, digits, `.`, `_`, and `-`, except `.` and `..`. `--skill` and `--rule` cannot be combined. `--alias` requires one of them.

```sh
skill-universe list
skill-universe rename <alias> <new-alias>
skill-universe update <alias>
skill-universe update all
skill-universe remove <alias>
skill-universe upgrade
skill-universe --help
```

Items with the same repository URL and branch share a checkout. Updating one updates them all. Local edits are allowed; updates require a fast-forward, disable automatic stashing, and refuse to overwrite ignored files. Failed merges retain recovery records and a lock; see below.

`upgrade` updates the tool from `https://github.com/seliverstov-maxim/skill-universe.git`, branch `main`, by default.

## Files and configuration

- Manifest: `~/.skill-universe/manifest.json`.
- Repository checkouts: `~/.skill-universe/repos/`.
- Skills: `~/.agents/skills/` for Codex; `~/.claude/skills/` for Claude.
- Rules: `~/.codex/rules/` for Codex; `~/.claude/rules/` for Claude.

Skills and rules are symlinked into the configured harness directories. The tool does not edit personal instruction or configuration files. For Codex, `init` prints a `developer_instructions` entry to add manually at the top level of `$CODEX_HOME/config.toml` (default `~/.codex/config.toml`). If the entry already exists, append the instruction to its value. Claude reads its user rules directory directly.

Edit `directory`, `rules_directory`, or the `upgrade` Git source in the manifest to change them. If you change the Codex rules directory, update your manual instruction too.

| Environment variable | Purpose / default |
| --- | --- |
| `SKILL_UNIVERSE_HOME` | State, manifest, cache and tool checkout: `~/.skill-universe`. |
| `SKILL_UNIVERSE_BIN_DIR` | Installer command directory: `~/.local/bin`. |
| `CODEX_HOME` | Codex configuration directory shown in the `init` instructions: `~/.codex`. Does not change installation destinations. |
| `SKILL_UNIVERSE_CODEX_SKILLS_DIR` / `SKILL_UNIVERSE_CODEX_RULES_DIR` | Codex paths stored by `init`. |
| `SKILL_UNIVERSE_CLAUDE_SKILLS_DIR` / `SKILL_UNIVERSE_CLAUDE_RULES_DIR` | Claude paths stored by `init`. |

State and installer overrides must be absolute paths. Harness paths may be absolute or start with `~/`. Harness environment overrides apply only during `init`; edit the manifest for an existing installation. Keep the state override consistent across commands.

## Repository structure

```text
repository/
|-- skills/
|   `-- skill-name/
|       `-- SKILL.md
`-- rules/
    `-- rule-name.md
```

- A skill requires `skills/<skill-name>/SKILL.md`. The entire directory is linked, including supporting files.
- A rule is `rules/<rule-name>.md`. No frontmatter is required; contents are preserved.
- Either directory may be omitted. Discovery covers immediate skill directories and immediate `.md` rule files. Root-level `SKILL.md`, nested rules and other rule extensions are ignored.
- Symlinks anywhere under `skills/` or `rules/`, including those directories themselves, are rejected. Updates check the incoming Git tree before applying it.
- `--skill` selects a directory name; `--rule` selects a filename without `.md`.

## File safety and recovery

Install and rename reject occupied destinations, including dangling links. Rename and remove require the registered installation symlink; substituted files or links are left alone.

Mutating commands use `~/.skill-universe/lock/`. Backups of links and the manifest are stored in `~/.skill-universe/transaction.*`. Ordinary errors and handled signals trigger file rollback; cached clones and newly created empty directories can remain.

Git changes are never reset automatically. Failed or interrupted merges retain the lock and transaction directory. `update all` saves progress per checkout; earlier successful updates remain applied.

If a lock remains after a failed merge, forced termination, power loss or failed rollback:

1. Confirm no related command or Git operation is running before removing its lock.
2. Inspect the retained transaction directory. Each `entry.*` records a `path`, an optional `original` backup, and a `ready` marker. Only entries with `ready` have complete backups. `git-pending` identifies a Git operation requiring inspection.
3. Reconcile links, backups and the manifest. Inspect Git changes before finishing or undoing them. Align all manifest entries sharing the repository URL and branch with the resulting HEAD. Do not blindly reset a checkout or restore an older manifest over a completed update.
4. Once state agrees, remove the recovered transaction directory and empty lock directory.

Rollback does not make Git and file changes atomic across filesystems or power loss. The tool does not sandbox skills or rules; install only repositories whose instructions you trust. Path overrides do not isolate execution. Use the [disposable verification environment](verification/README.md) when checking untrusted code.
