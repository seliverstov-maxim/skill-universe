# Contribution workflow

- Make all repository changes on a separate branch and submit them through a pull request targeting `main`.
- Do not commit or push changes directly to `main`.
- Ensure the pull request's required checks pass before merging.

# Internal audit

- Every pull request must include a new internal audit following [SU-SEC-1](docs/security/methodology.md) and [SU-DECL-1](docs/security/declared-behavior-methodology.md), performed by a fresh review agent without the implementation conversation or previous findings.
- Include a Yes/No answer and source evidence for every SU-DECL-1 question in the report; identify mismatches, undeclared behavior and insufficient evidence explicitly.
- Replace [the current report](docs/security/report.md) with the new assessment; keep only the latest report.
- Identify the exact reviewed source commit in the report. Any subsequent change to the reviewed files requires a new audit before merging; updating the report and its generated badge does not require recursively auditing those outputs.
- Resolve actionable findings and repeat the review in a fresh context until none remain before merging. Automated scanners do not replace this audit.

- After updating the audit report, run `python3 scripts/generate-audit-badge.py` and commit `docs/security/audit.svg` with it. CI checks that report coverage, reviewed source and the generated badge agree; this check does not perform the audit.
