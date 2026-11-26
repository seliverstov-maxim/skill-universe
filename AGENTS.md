# Contribution workflow

- All contributors, including maintainers and coding agents, start working branches from the latest `develop` and submit ordinary changes through pull requests targeting `develop`.
- Do not commit or push changes directly to `develop` or `main`.
- `develop` is the integration branch. Ordinary pull requests do not require a version bump, release audit reports or regenerated release badges.
- `main` contains prepared releases and remains the default branch used by installation, tool upgrades and GitHub Pages. Do not change the default branch without first making the installer explicitly select `main`.
- Follow [CONTRIBUTING.md](CONTRIBUTING.md) for contributions and [RELEASING.md](RELEASING.md) for the separate maintainer release flow.
- Ensure the pull request's required checks pass before merging.

# Internal audit

- Maintainers prepare releases through working branches and pull requests into `develop`, then open a release pull request from this repository's `develop` to `main`. Do not release directly from a feature branch or a fork.
- Every release must publish fresh SU-SEC-1 and SU-DECL-1 reports and their matching badges for the released source. Update VERSION, visible release markers and version-specific cross-links together. After the release pull request is merged, create an annotated tag on the released `main` commit using `v` followed by the exact VERSION value (for example `v2.0.01`). The tagged commit must include the reports.
- Release preparation requires a new internal audit following [SU-SEC-1](docs/security/methodology.md) and [SU-DECL-1](docs/security/declared-behavior-methodology.md), performed by a fresh review agent without the implementation conversation or previous findings. This is a maintainer responsibility, not a condition for ordinary contributions to `develop`.
- Include a Yes/No answer for every SU-DECL-1 question, and separate code-review and observed-result columns with evidence/limits. Use the repository prompt and manual verification scenarios; do not claim unperformed behavior checks passed.
- Update the separate current reports: [SU-SEC-1](docs/security/security-report.json) and [SU-DECL-1](docs/security/declared-behavior-report.json). Keep only the latest report for each methodology.
- Identify the exact reviewed source commit in the report. Any subsequent change to the reviewed files requires a new audit before release; updating the two result JSON files and their generated badges does not require recursively auditing those outputs. Reports on `develop` may describe the last release and must not be presented as an audit of unreleased changes.
- Resolve actionable source/runtime findings and repeat review in a fresh context before release. A live check of an unpublished candidate may remain explicitly incomplete until deployment; do not display a passing badge for it. Complete that check after publication and before tagging the release. Automated scanners do not replace this audit.

- Each report must set its JSON `result` field to `passing`, `failing` or `incomplete`. Use passing only after completing its methodology without open findings, mismatches or insufficient evidence.
- After updating both reports, run `sh scripts/generate-audit-badges.sh` and commit both generated SVG badges with them. CI checks report coverage, reviewed source and badge agreement; it does not perform the audits.

# Allowed stack

- CLI, installers and repository maintenance scripts: POSIX `sh`, Git, `jq` and standard Unix utilities.
- Website and report pages: plain HTML, CSS, vanilla JavaScript, JSON and SVG. No frontend framework or build system.
- CI configuration: GitHub Actions YAML and the existing checks (ShellCheck, CodeQL, OpenSSF Scorecard, Gitleaks, zizmor and ClamAV).
- Docker is allowed for isolated verification and CI scanning; it is not a CLI runtime dependency.
- Ask the user for explicit permission before introducing any additional language, runtime, dependency, package manager, framework, build tool, scanner or external service. Availability on the machine does not constitute permission.
- Python is not part of the allowed stack.
