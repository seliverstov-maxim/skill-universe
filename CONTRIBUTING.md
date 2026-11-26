# Contributing

Send ordinary pull requests to **`develop`**, including changes from maintainers and coding agents. `main` is reserved for prepared releases.

1. Fork the repository, fetch the upstream `develop` branch, and create a working branch from it.
2. Keep the change focused. Describe the problem, resulting behavior and any compatibility changes.
3. Check the affected behavior and include what you actually checked in the pull request. Use the [manual verification environment](verification/README.md) for CLI changes; do not use personal configuration or credentials as fixtures.
4. Open a pull request with this repository's `develop` as the base branch. The default branch remains `main` for installation, so select `develop` explicitly.

Ordinary contributions do **not** need a version bump, internal release reports or regenerated release badges. Maintainers prepare these in the separate [release flow](RELEASING.md); no write access to a contributor's fork is needed for release reports.

The allowed implementation stack is listed in [AGENTS.md](AGENTS.md#allowed-stack). Discuss additional dependencies or languages before introducing them. Update relevant usage documentation when behavior changes, and avoid unrelated formatting changes.

Required CI checks must pass before merging. Automated checks do not replace review. Report vulnerabilities using the process in [SECURITY.md](SECURITY.md).

The reports and badges retained on `develop` describe their recorded release source, not subsequent unreleased changes. Published reports on the website describe the released `main` source recorded in each report.
