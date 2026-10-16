# Maintainer release flow

`develop` receives ordinary contributions from everyone, including maintainers. `main` receives prepared releases through pull requests from this repository's `develop`. Installation and `upgrade` continue to use `main`; skill/rule `update` continues to use each item's configured source.

Keep `main` as the GitHub default branch and the GitHub Pages source (`main`, `/docs`). The current installer clones the default branch. Do not switch the default to `develop`: that would deliver unreleased code. Contributors select `develop` explicitly when opening pull requests.

## Prepare the release on develop

1. Start a release preparation working branch from the latest `develop`. Check that changes intended for the release are present and that the released `main` history is included.
2. Update `VERSION`, using the project's format, for example `2.0.01`. Update the README and website release markers and all version-specific links to the matching `v2.0.01` tag. Describe breaking changes where applicable. Do not create the tag yet.
3. Freeze a source commit and perform fresh [SU-SEC-1](docs/security/methodology.md) and [SU-DECL-1](docs/security/declared-behavior-methodology.md) assessments. Use a fresh source-review agent and record actual manual observations separately. Fix findings and repeat the required review/checks after source changes.
4. Commit both current result JSON files and their generated SVG badges. Record the reviewed source commit and full source inventory. The four result/badge outputs are excluded from their own inventory; they can follow the reviewed source commit.
5. Run `sh scripts/generate-audit-badges.sh --check`. Check version markers, cross-links, installer copies, relevant manual scenarios and the required CI checks. An internally consistent report is not evidence that the audit occurred.
6. Open a pull request into `develop` for the prepared release. Retain the reviewed source commit in history when merging release preparation; do not squash or rebase it away. Freeze the release contents while promotion is in progress. Any further source change requires a fresh audit before release.

## Promote and publish

1. Open a release pull request **`develop` → `main`**. Ordinary contribution pull requests must not target `main`.
2. Confirm the final source bytes match the reports, both methods have the required evidence, version markers/cross-links agree, and required CI checks pass. Use a merge commit so source history and the recorded audit commit remain reachable.
3. After merging, check the actual published website → installer → Git source chain. If candidate delivery was incomplete before deployment, complete that observation and prepare the result/badge-only update through a working branch → `develop` → `main`. Keep the same source inventory and release version for this output-only follow-up. Do not label unperformed checks as passing.
4. Once the released source, reports and publication checks are ready, create an annotated tag on the resulting `main` commit: `v` plus the exact `VERSION` value, for example `v2.0.01`. Push the tag. Tags must not be moved or reused, and no release tag is created for an ordinary development pull request.
5. Check that the tag, version-specific README/website links and reports resolve to the intended release. Synchronize the released `main` history back into `develop` through a pull request before the next release preparation if needed.

Publishing the default-branch clone is the release promotion step; the tag records that prepared release. This flow adds no version-discovery service or dependency to the CLI. After a release, subsequent development may make its reports stale for `develop`; do not regenerate them merely to merge an ordinary contribution.
