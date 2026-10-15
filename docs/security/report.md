# Security verification

- Status: **Completed review; open findings. Do not interpret as “verified safe”.**
- Reviewed commit: [`0b0b6d1b47dc631577e6aac62d5107bc5ba248f4`](https://github.com/seliverstov-maxim/skill-universe/tree/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4)
- Review date: 2026-10-15
- Reviewer: Codex, at the maintainer's request; AI-assisted review, not independent certification
- Procedure: [SU-SEC-1, version 1](methodology.md)
- Replay: [reproduce.py](reproduce.py)
- Recorded evidence: [results.json](results.json)

This is the single current report. Future reviews replace it and its evidence. The SHA identifies the code that was reviewed; the report is necessarily added in a later documentation commit. Uncommitted README changes, the audit runner itself, future code changes, and newly downloaded third-party content are not part of that source snapshot. The evidence includes SHA-256 hashes of the reviewed distributed files.

## Summary

The same 15 boundary checks ran on macOS and Linux: **10 passed and 5 failed** on each platform. The five failed checks demonstrate four open findings below. No production code was changed to obtain these results.

A literal shell-expression alias did not execute commands. A repository payload script was not executed by installation. Normal managed-block removal preserved personal instructions. Duplicate aliases were rejected, and a conflicting Git update preserved both the manifest and local edits. The actual bootstrap and self-upgrade were exercised through local Git fixtures, not through a remote download.

These positive results do not cancel the filesystem weaknesses below. No remote shell execution or network exfiltration was demonstrated. Live agent behavior was not tested.

## Open findings

### SU-01 — Aliases can escape installation directories

- Priority: medium
- Preconditions: a user supplies an alias containing path components; this is not reached through an ordinary repository filename alone.
- Checks: C03 and C04
- Classification: [CWE-22](https://cwe.mitre.org/data/definitions/22.html)

`remove ../../outside.txt` deleted a sentinel file outside the configured skill directory even though the alias was not in the manifest. `install ... --skill=demo --alias=../outside` created a link outside the skill installation directory. Both actions ran only inside temporary test HOME directories.

Source evidence: [install.sh:61–76](https://github.com/seliverstov-maxim/skill-universe/blob/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4/commands/install.sh#L61-L76) inserts the alias into a destination path; [remove.sh:6–13](https://github.com/seliverstov-maxim/skill-universe/blob/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4/commands/remove.sh#L6-L13) does not require a registered alias before calling rm. [rename.sh:17–19](https://github.com/seliverstov-maxim/skill-universe/blob/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4/commands/rename.sh#L17-L19) uses the same unconstrained path construction, though traversal through rename was not separately replayed.

Required boundary: an alias must be a single destination name, and remove/rename must address an installed entry. Reject escaping paths before filesystem mutation.

### SU-02 — Rename overwrites an unmanaged destination file

- Priority: medium
- Preconditions: an ordinary user rule file already exists under the requested new alias, but is not registered in the manifest.
- Check: C05

After installing `style`, the replay created a personal `personal.md` file. `rename style personal` replaced that file with the installed rule's symlink, losing its original text. No specially crafted path or malicious repository was required.

Source evidence: [rename.sh:12–19](https://github.com/seliverstov-maxim/skill-universe/blob/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4/commands/rename.sh#L12-L19) checks manifest aliases but not existing filesystem destinations; mv replaces a regular destination file.

Required boundary: reject an occupied destination in every configured harness, including unmanaged files and dangling links, before moving any installed links.

### SU-03 — Repository symlinks can publish host files as global rules

- Priority: medium
- Preconditions: a source repository contains a rule symlink aimed outside its checkout, and the target exists on the user's machine.
- Check: C06

The source repository supplied `rules/host.md -> ../../../../private.md`. Once cloned into the normal cache layout, this resolved to a sentinel file in the test user's home directory. Installation accepted it and exposed that host file as `~/.codex/rules/host.md`.

Source evidence: [install.sh:44–54](https://github.com/seliverstov-maxim/skill-universe/blob/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4/commands/install.sh#L44-L54) accepts a rule using a file check that follows symlinks; [line 76](https://github.com/seliverstov-maxim/skill-universe/blob/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4/commands/install.sh#L76) links that path into the harness without checking its resolved location.

This demonstrates exposure in the rule namespace, not automatic exfiltration. The replay read the sentinel itself to confirm the target; no live agent was used. A hash of the repository's symlink does not cover the contents of the external host file. Trusted instructions already have broad agent capabilities, but that does not make the outside target part of the reviewed repository.

Required boundary: constrain resolved installed sources to the intended checkout, or explicitly reject source symlinks. Apply the chosen policy to enclosing directories too; document whether internal symlinks are supported.

### SU-04 — A missing block terminator deletes following personal instructions

- Priority: low
- Preconditions: the user or another local process has removed the managed end marker from AGENTS.md after rule installation.
- Check: C08

The replay retained the start marker but omitted the end marker, then placed personal text after it. Removing the last rule deleted everything from the start marker to the end of the file, including the personal text.

Source evidence: [codex-rules.sh:18–19](https://github.com/seliverstov-maxim/skill-universe/blob/0b0b6d1b47dc631577e6aac62d5107bc5ba248f4/commands/codex-rules.sh#L18-L19) uses an unvalidated sed range and writes its result back.

Required boundary: if the complete managed block cannot be identified, leave the file unchanged and report that removal needs attention. This is a local integrity risk, not a demonstrated remote attack.

## Boundary check matrix

| Check | Property | macOS | Linux |
| --- | --- | --- | --- |
| C01 | Alias shell expressions are not evaluated | PASS | PASS |
| C02 | Repository payload scripts are not executed during install | PASS | PASS |
| C03 | Remove stays within installation paths | FAIL | FAIL |
| C04 | Install aliases stay within installation paths | FAIL | FAIL |
| C05 | Rename preserves unmanaged destination files | FAIL | FAIL |
| C06 | Installed rules resolve inside the source checkout | FAIL | FAIL |
| C07 | Normal last-rule removal preserves personal AGENTS.md text | PASS | PASS |
| C08 | An incomplete managed block preserves following personal text | FAIL | FAIL |
| C09 | Duplicate aliases fail without manifest changes | PASS | PASS |
| C10 | A conflicting update preserves local edits and manifest | PASS | PASS |
| C11 | Distributed shell sources parse | PASS | PASS |
| C12 | Root and Pages installers have identical contents | PASS | PASS |
| C13 | Bootstrap creates the expected tool checkout and command link | PASS | PASS |
| C14 | Bootstrap preserves an existing regular command file | PASS | PASS |
| C15 | Self-upgrade obtains the configured Git source | PASS | PASS |

The runner exits 1 when any property fails. The raw output and commands are in results.json. Repeating the run should reproduce the properties, not the random temporary paths or fixture Git commit IDs.

## Static analysis and source review

ShellCheck 0.10.0 returned six diagnostics and exit status 1:

- Three SC2088 warnings in install, rename, and remove. The quoted `~/` text is deliberately matched as a literal case pattern, then explicitly expanded with HOME. This is an intentional use, not the missing tilde expansion described by the warning. See [SC2088 exceptions](https://www.shellcheck.net/wiki/SC2088).
- Three SC2016 informational messages in the two installers and the Codex block writer. Dollar signs for shell-profile output and Markdown backticks are deliberately literal printf text. See [SC2016 exceptions](https://www.shellcheck.net/wiki/SC2016).

All six diagnostics were reviewed; no suppressions were added. ShellCheck did not detect the confirmed filesystem issues.

The baseline source review traced every CLI command, both installers, fixed command dispatch, Git operations, jq argument passing, symlink handling, temporary state writes, and the static website's active script. No eval, execution of source Markdown, source install hook, analytics SDK, or separate telemetry endpoint was found in these files. The website script copies the installation command to the clipboard; the user initiates that action. Git remains responsible for network protocols and authentication.

## Trust and unverified limits

The installer URL and self-update branch are mutable: this review of a pinned SHA is not a promise about future content served from main. Installed skills and rules can instruct an agent to perform unsafe actions; they are not sandboxed or vetted by this tool. An SSH/HTTPS source may also involve credential helpers, Git configuration, and hooks already configured by the user. Their implementations were not audited.

The review did not exhaustively test concurrency, power loss, arbitrary corrupt manifests, every alias character, remote protocol behavior, browser security headers, all link configurations, or all platform versions. Predictable temporary files and unsynchronized manifest writes remain areas for follow-up. No exploit across a different OS user's permissions was established for those observations. The ordinary CLI has the invoking user's privileges.

## Recorded environment

- macOS/arm64: Python 3.14.7, Apple Git 2.54.0, jq 1.8.1; sh reported GNU bash 3.2.57.
- Linux/arm64: Debian 13, Python 3.11.14, Git 2.47.3, jq 1.7, ShellCheck 0.10.0; `/bin/sh` from the image.
- Linux audit image ID: `sha256:7737254e364266384729581f348fcfb174f3ea0b8cb9063a62e65a77cfc269e4`.
- Base image digest: `python:3.11-slim@sha256:fa9b525a0be0c5ae5e6f2209f4be6fdc5a15a36fed0222144d98ac0d08f876d4`.
- Execution environments and Git/jq versions are also recorded in the raw evidence. No dependency vulnerability scan, formal verification, or live Codex/Claude session is claimed.

## Reproduce or challenge this report

Follow [the exact commands and assumptions](methodology.md#reproduce-the-boundary-checks). Inspect [the replay source](reproduce.py), compare the source hashes in [results.json](results.json), and rerun against the pinned commit. Report differing outcomes with the tool versions, full source SHA, and command output. A valid reproduction disagreement should change the report.
