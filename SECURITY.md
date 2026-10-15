# Security policy

## Supported versions

Security fixes are applied to the latest code on `main`. Older commits and historical versions do not have a separate security maintenance commitment. Include the exact commit SHA in a vulnerability report.

## Reporting a vulnerability

Report vulnerabilities privately through [GitHub private vulnerability reporting](https://github.com/seliverstov-maxim/skill-universe/security/advisories/new). If that form is unavailable, email the maintainer at [maxim.web.developer@gmail.com](mailto:maxim.web.developer@gmail.com).

Describe the affected command, commit, required access, steps to reproduce, and likely impact. Use a minimal example without credentials or personal data. Please keep exploit details out of public issues while the report is being assessed.

## Coordinated disclosure

The maintainer will assess reports on a best-effort basis and coordinate a fix and public disclosure with the reporter. There is no guaranteed response or remediation deadline. Disclosure should explain affected versions, impact, and the available fix or mitigation.

## Scope

The tool's installer, CLI, GitHub workflows, and delivery of skills/rules are in scope. Third-party skills and rules remain their authors' responsibility; distribution does not sandbox or certify their instructions. See the [source review and its limits](docs/security/report.md).
