# Security verification methodology

- Procedure: SU-SEC-1
- Version: 1
- Scope: the Skill Universe CLI, both distributed installers, and the static website
- Review type: maintainer-requested, AI-assisted baseline source review plus executable boundary checks

This is the project's reproducible review procedure, informed by the sources below. It is not OWASP certification, an OpenSSF score, a formal proof, or an OpenAI endorsement.

## References and how they are applied

| Reference | Application in this review |
| --- | --- |
| [OWASP Secure Code Review Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html) | Baseline review; inspect entry points, trace input to filesystem/process operations, and check errors and deployment behavior. |
| [OWASP Threat Modeling](https://community.owasp.org/Threat_Modeling) | Identify assets, trust boundaries, abuse cases, controls, and remaining risks before interpreting scan results. |
| [MITRE CWE-22: Path Traversal](https://cwe.mitre.org/data/definitions/22.html) | Classify aliases that can address paths outside the installation directory. |
| [MITRE CWE-61: UNIX Symlink Following](https://cwe.mitre.org/data/definitions/61.html) | Guide examination of link targets and unintended filesystem access; CWE labels describe weakness classes, not certifications. |
| [ShellCheck](https://www.shellcheck.net/) | Supplemental shell diagnostics; every diagnostic is manually triaged. A clean scan would not establish application security. |

The STRIDE categories are used as prompts for relevant threats, not as a claim that every possible attack is covered. HTTP authentication, browser sessions, and application cryptography are not implemented by this CLI and are not treated as applicable web audit requirements.

## Threat model

### Assets

User files outside the managed installation paths; existing skills and rules; global AGENTS.md instructions; manifest integrity; local skill development; the identity and contents of downloaded code; and credentials used by Git.

### Inputs and boundaries

1. CLI arguments supply repository URLs, branches, selectors, and aliases.
2. A source repository controls tracked paths, contents, executable bits, and symlinks. Installing instructions does not make all its paths trustworthy.
3. The manifest supplies destinations, sources, and saved state. It is user configuration, not an untrusted network response.
4. The CLI translates those inputs into Git operations, filesystem links, file writes, and a managed AGENTS.md block.
5. Codex or Claude later reads the delivered instructions. Their execution of those instructions is a separate trust boundary.
6. The bootstrap and self-update source provide executable tool code, with the invoking user's filesystem privileges.

### Assumptions

- The OS, shell, Git, jq, Python used for reproduction, and the initial reviewed tool snapshot are trusted.
- No privileged/root execution is required. The tool is not a sandbox for hostile skills or rules.
- An attacker who already controls all files or executable configuration of the same OS account is outside the meaningful isolation boundary. Predictable temporary paths are noted, but not presented as privilege escalation without an additional permission boundary.
- User-controlled aliases are still checked for confinement and collision behavior. A finding requiring a crafted CLI argument is distinguished from one reachable through repository contents alone.
- Downloaded Markdown can contain malicious agent instructions by design. This review does not certify the content of third-party skills, rules, or future updates.

### Threat prompts

| Category | CLI-specific question |
| --- | --- |
| Spoofing | Is the reviewed revision distinguishable from a moving source branch? |
| Tampering | Can aliases, links, collisions, or managed-block edits change unrelated files? |
| Repudiation | Are the source SHA, commands, environment, and results recorded? |
| Information disclosure | Can repository links expose host files as globally loaded rules? Are secrets or payloads transmitted? |
| Denial of service | Can malformed configuration or interrupted writes damage instruction/state files? |
| Elevation of privilege | Can data become shell commands or gain broader filesystem reach than the advertised operation? No OS privilege escalation is assumed. |

## Execution procedure

1. Resolve the full source commit. Export that commit rather than testing the mutable working tree. Inventory and hash the distributed executable and site files.
2. Read every shell entry point, installer, command implementation, and the website's active JavaScript. Trace URL, branch, alias, path, manifest, and source-file flows into Git, sh, ln, mv, rm, sed, and file redirections.
3. Classify findings by reachability and impact. Do not equate a malicious repository with a malicious local manifest or a crafted command argument.
4. Execute `reproduce.py` using disposable HOME directories and local Git fixtures. Subprocesses use an explicit environment, ignore global/system Git configuration, and allow only Git's file transport. Bootstrap HTTPS is rewritten by Git to a local copy of the reviewed tool; it is not fetched from the internet.
5. Run the same checks on macOS and Linux. The recorded Linux replay uses `--network none` and a read-only source mount. Source tool files and actual user configuration are never modified by the replay.
6. Run ShellCheck on the exported shell files and review all output, including warnings judged intentional. Check source syntax and duplicate installer contents.
7. Record an issue only with source evidence and an observed reproduction, or explicitly label it as an untested limitation. Passing checks establish only the stated property under the tested conditions.
8. Publish the current report, raw replay transcripts, file hashes, and reproduction procedure together. Keep one current report rather than date/SHA-named historical report files.

## Result meanings

- **PASS:** the stated boundary property held in the recorded fixture.
- **FAIL:** the stated property was violated; inspect the evidence and issue preconditions.
- **Not tested:** no empirical result is claimed.

Priority in this report is a contextual reviewer judgment, not a computed CVSS score: medium for confirmed filesystem boundary/data-loss weaknesses requiring a user action; low for damage after manual corruption of an internal marker. A review may finish successfully while its security checks fail. Findings remain open until a new review confirms their fixes.

## Reproduce the boundary checks

Requirements: Git, jq, a POSIX `sh`, and Python 3.11.8 or newer (standard library only). No tool installation or actual skill installation in your real user profile is performed.

From a checkout containing these reports:

```sh
python3 docs/security/reproduce.py . --output /tmp/skill-universe-security-results.json
```

The default source SHA is pinned in the reproducer and matches the report. Check another revision explicitly with `--revision=<full-sha>`; doing so is a new run, not evidence that the published review covers that revision. Keep the output outside the repository unless intentionally replacing the current evidence.

At the reviewed SHA, the expected exit status is **1**, with **10 PASS and 5 FAIL**. A failure here demonstrates an open issue; it must not be reinterpreted as a successful security badge. Exit status 0 means all implemented checks passed, not proof that no other vulnerabilities exist.

The JSON output includes every exercised command and its exit status/stdout/stderr. Sandbox paths are replaced with `<sandbox>` in transcripts. The temporary HOME directories and Git fixtures are removed after the run. No nondisposable files are used as traversal or overwrite targets.

### Repeat in Linux without network access

Prepare the tool image once (package installation needs network access):

```sh
docker build -t skill-universe-security-audit - <<'DOCKERFILE'
FROM python:3.11-slim@sha256:fa9b525a0be0c5ae5e6f2209f4be6fdc5a15a36fed0222144d98ac0d08f876d4
RUN apt-get update -qq && apt-get install -y -qq git jq shellcheck && rm -rf /var/lib/apt/lists/*
DOCKERFILE
```

Run the replay as the repository owner so Git does not reject the bind mount as dubious ownership:

```sh
audit_output=$(mktemp -d)
docker run --rm --network none \
  --user "$(id -u):$(id -g)" -e HOME=/tmp \
  --mount "type=bind,source=$PWD,target=/repo,readonly" \
  --mount "type=bind,source=$audit_output,target=/evidence" \
  skill-universe-security-audit \
  python3 /repo/docs/security/reproduce.py /repo \
  --output /evidence/results-linux.json
```

The recorded package versions are in the report. The base image is pinned; apt package indexes can change, so this recipe promises repeatable test cases, not bit-for-bit reproducible tool images. Building the image does not run the project installer.

### Repeat ShellCheck on the exact source

```sh
audit_source=$(mktemp -d)
git archive 0b0b6d1b47dc631577e6aac62d5107bc5ba248f4 | tar -x -C "$audit_source"
docker run --rm --network none \
  --mount "type=bind,source=$audit_source,target=/source,readonly" \
  skill-universe-security-audit sh -c \
  'cd /source && shellcheck --format=json skill-universe install.sh docs/install.sh commands/*.sh'
```

ShellCheck 0.10.0 produced six diagnostics and exit status 1. Their triage is recorded in the report; none are silently suppressed in this command.

## Limits

This procedure does not establish formal verification, exhaustive input coverage, or the absence of hidden behavior in dependencies. It does not audit Git's implementation, verify an SSH/HTTPS server, inspect every network syscall, test every OS/filesystem, execute live Codex/Claude sessions, or validate future revisions of a moving branch. It also does not provide an independent review: Codex assisted both the implementation and this review. The evidence and procedure are public so another reviewer can repeat and challenge the conclusions.
