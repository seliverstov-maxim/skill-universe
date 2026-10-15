# Security review

- Judgment: **Security concerns identified. An unconditional “verified safe” claim is not supported.**
- Reviewed commit: [`9562183510908bb3c0afb8e185a0acdb2c812121`](https://github.com/seliverstov-maxim/skill-universe/tree/9562183510908bb3c0afb8e185a0acdb2c812121)
- Date: 2026-10-15
- Reviewer: Codex; also involved in implementation, not an independent auditor
- Method: [SU-SEC-1, version 2](methodology.md), agent source-code review

This is the single current report. It assesses committed application source at the SHA above. The replacement methodology and this report are documentation changes added afterward. The old audit runner and its recorded results are excluded from application coverage and removed by this documentation change. The conclusions below come from reading code; no runtime checks, scanners, or platform execution form part of this assessment.

## Assessment

No telemetry endpoint, analytics integration, or separate payload execution was identified in the reviewed application source. Command dispatch is fixed; arguments passed to jq use data parameters; installed Markdown is linked rather than executed by the installer. The website's active script writes the displayed installation command to the clipboard after a click.

The implementation nevertheless has filesystem and instruction-integrity weaknesses. Use assumes trusted repositories, ordinary aliases, and an intact local configuration; even then, rename can replace an unmanaged destination. Git, shell, jq, agent behavior, and future branch contents are outside this assessment. This review does not justify claiming that installing arbitrary repositories is safe.

## Coverage and checklist

Files read: `skill-universe`; all ten files under `commands/` (`init`, `install`, `list`, `rename`, `update`, `remove`, `upgrade`, `version`, `help`, `codex-rules`); `install.sh`; `docs/install.sh`; `docs/index.html`; `docs/style.css`; `docs/icon.svg`; `docs/sitemap.xml`; `VERSION`; and README for intended behavior. There are no runtime package dependencies declared in the reviewed tree beyond external commands.

| Item | Result | Source-based reasoning |
| --- | --- | --- |
| R01: undeclared communication | No issue identified | Network operations in the CLI and installers are Git source discovery, clone, and pull. Website assets are local and its active script only handles clipboard copying. Git's own transports and configuration are outside scope. |
| R02: code injection | No issue identified | Dispatcher accepts a fixed command set. Input variables are quoted in subprocess calls, jq values use `--arg`, and no eval or execution of downloaded skill/rule scripts appears in the application source. See [dispatcher](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/skill-universe), [install](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/install.sh), and [website script](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/docs/index.html#L77-L90). |
| R03: path confinement | Issue identified | Aliases are appended to destination paths without basename validation; remove/rename do not require a registered source alias. SU-01. |
| R04: source links | Issue identified | File checks follow source symlinks, and resolved targets are not confined to the checkout. SU-03. |
| R05: unrelated files | Issue identified | Rename checks manifest aliases but not unmanaged destination files. SU-02. Bootstrap and install also lack a complete destination-symlink policy; see unresolved details below. |
| R06: personal instructions | Issue identified | The deletion range is not validated for a matching end marker. SU-04. |
| R07: updates and failure handling | Issue identified | Pull uses `--ff-only`, with no explicit reset/stash in the code. Shared temporary filenames and sequential filesystem/state writes lack transaction or concurrency controls. SU-05. No general preservation guarantee follows from `--ff-only`. |
| R08: update trust | No issue identified within stated trust model | Bootstrap clones the public tool repository, and upgrade pulls the configured source. Both are explicit operations, but moving branches do not authenticate future code as reviewed. See [installer](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/install.sh) and [upgrade](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/upgrade.sh). |

## Findings

These are source-based conclusions, not claims of executed exploits. Priorities are contextual judgments, not computed CVSS scores.

### SU-01 — Aliases can address paths outside installation directories

**Medium.** A user must supply a crafted alias. [Install lines 61–76](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/install.sh#L61-L76) append the alias to a harness directory without rejecting path components. [Remove lines 6–13](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/remove.sh#L6-L13) default to a skill even when no manifest entry exists, then pass the constructed path to rm. An alias such as `../../outside.txt` can therefore address an existing file outside the skill directory. [Rename lines 17–19](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/rename.sh#L17-L19) construct paths in the same way.

This is not an ordinary repository author choosing a simple filename. Require single-component aliases and registered entries before remove/rename operations. Classification: [CWE-22](https://cwe.mitre.org/data/definitions/22.html).

### SU-02 — Rename can replace an unmanaged file

**Medium.** A personal file must already occupy the new alias path. [Rename lines 12–19](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/rename.sh#L12-L19) reject only aliases recorded in the manifest, then call mv. Renaming a rule to the stem of an existing regular `.md` file can replace that file with the installed link.

Check actual destinations, including dangling links, before moving installed entries in any harness.

### SU-03 — Source symlinks can expose host files as rules

**Medium.** A repository author can supply a rule symlink aimed outside the checkout; its target must exist on the user's host. [Install lines 44–54](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/install.sh#L44-L54) use file checks that follow symlinks; [line 76](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/install.sh#L76) links the accepted path into the harness without resolving its boundary. A relative link such as `rules/host.md -> ../../../../private.md` can resolve outside the normal cached checkout. Skill source directories need the same examination.

This makes external file content available through the installed instruction path. Actual agent reads or exfiltration are not established by source review. Constrain resolved sources and parent directories to the checkout, or reject external source links. Classification: [CWE-61](https://cwe.mitre.org/data/definitions/61.html).

### SU-04 — An incomplete managed block can remove personal instructions

**Low.** A user or local process must have removed the end marker. [Codex block removal lines 18–19](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/codex-rules.sh#L18-L19) delete a sed range from the start marker to the end marker without checking that the latter exists. With no end marker, the range extends to EOF, including subsequent personal text.

Leave AGENTS.md unchanged when a complete managed block cannot be identified.

### SU-05 — State changes are not transactional

**Low.** Interruption, an error partway through an operation, or concurrent commands can leave links and manifest state inconsistent. [Install lines 73–87](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/install.sh#L73-L87) create links before recording the entry. [Rename](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/rename.sh#L17-L24) and [remove](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/remove.sh#L11-L17) also mutate filesystem entries before committing state. Writers reuse `manifest.json.tmp` without locking. [Codex block removal](https://github.com/seliverstov-maxim/skill-universe/blob/9562183510908bb3c0afb8e185a0acdb2c812121/commands/codex-rules.sh#L18-L20) similarly uses a fixed temporary file and truncates the destination before copying completes.

These are visible failure paths; their frequency and platform-specific consequences are not established. Document the limitation or introduce coordinated writes and recovery if stronger preservation is required. No cross-user privilege escalation is claimed.

## Unresolved details and limits

Destination symlinks and pre-existing directories are not consistently checked before ln/mv operations. These utilities can interpret a destination directory as a container, potentially creating a nested entry instead of the intended alias. The full consequences across symlink configurations and platforms remain unresolved by this review.

The reviewed shell scripts do not audit Git credential helpers, transports, configured hooks, or other user/environment configuration. Reading them does not establish the behavior of those dependencies. Downloaded Markdown may contain unsafe instructions; distributing it does not vet or sandbox it.

The source contains no explicit background service, scheduler, or telemetry sender. That observation covers the reviewed application files only. A later installer download, upgrade, third-party repository, or dependency can differ.

## Repeat the review

Read [the methodology](methodology.md), inspect the immutable source links above, trace each checklist item, and replace this report with an independently reasoned assessment of the desired full commit SHA. No test runner or scanner is required. Record disagreements with source evidence and clearly distinguish established code behavior from unresolved runtime questions.
