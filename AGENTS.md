# Contribution workflow

- Make all repository changes on a separate branch and submit them through a pull request targeting `main`.
- Do not commit or push changes directly to `main`.
- Ensure the pull request's required checks pass before merging.

# Internal audit

- Every pull request must include a new internal audit following [SU-SEC-1](docs/security/methodology.md) and [SU-DECL-1](docs/security/declared-behavior-methodology.md), performed by a fresh review agent without the implementation conversation or previous findings.
- Include a Yes/No answer for every SU-DECL-1 question, and separate code-review and observed-result columns with evidence/limits. Use the repository prompt and manual verification scenarios; do not claim unperformed behavior checks passed.
- Update the separate current reports: [SU-SEC-1](docs/security/security-report.json) and [SU-DECL-1](docs/security/declared-behavior-report.json). Keep only the latest report for each methodology.
- Identify the exact reviewed source commit in the report. Any subsequent change to the reviewed files requires a new audit before merging; updating the two result JSON files and their generated badges does not require recursively auditing those outputs.
- Resolve actionable source/runtime findings and repeat review in a fresh context before merging. A live check of an unpublished candidate may remain explicitly incomplete until deployment; do not display a passing badge for it. Complete that check after publication. Automated scanners do not replace this audit.

- Each report must set its JSON `result` field to `passing`, `failing` or `incomplete`. Use passing only after completing its methodology without open findings, mismatches or insufficient evidence.
- After updating both reports, run `sh scripts/generate-audit-badges.sh` and commit both generated SVG badges with them. CI checks report coverage, reviewed source and badge agreement; it does not perform the audits.

# Allowed stack

- CLI, installers and repository maintenance scripts: POSIX `sh`, Git, `jq` and standard Unix utilities.
- Website and report pages: plain HTML, CSS, vanilla JavaScript, JSON and SVG. No frontend framework or build system.
- CI configuration: GitHub Actions YAML and the existing checks (ShellCheck, CodeQL, OpenSSF Scorecard, Gitleaks, zizmor and ClamAV).
- Docker is allowed for isolated verification and CI scanning; it is not a CLI runtime dependency.
- Ask the user for explicit permission before introducing any additional language, runtime, dependency, package manager, framework, build tool, scanner or external service. Availability on the machine does not constitute permission.
- Python is not part of the allowed stack.
