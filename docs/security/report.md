# Security review

- Judgment: **No actionable security issue identified within the reviewed scope and stated trust assumptions.**
- Status: **Completed fresh-context source review; committed files match the reviewed snapshot.**
- Reviewed by Codex at [`06e488cfef9586197112bf0a37d5c6ce90e2b7b2`](https://github.com/seliverstov-maxim/skill-universe/tree/06e488cfef9586197112bf0a37d5c6ce90e2b7b2).
- Date: 2026-10-15
- Procedure: [SU-SEC-1, version 3](methodology.md).
- Source-set SHA-256: `6c5f35339fb523849b28fd3f8ecc7db4377215cf28762e57c897511e033d904d`.
- Reviewer: a fresh-context Codex agent, separate from the implementing agent, which did not contribute implementation changes. This is AI-assisted review, not independent institutional certification.

This is the single current report. The reviewer read all 31 scoped files completely from the frozen committed snapshot, without implementation conversation, earlier reports, history/diffs, local review notes or other reviewers' conclusions. It did not execute the CLI, installers, tests, scanners or repository payloads. No runtime check is represented as passed.

The implementing agent subsequently read each covered committed file and compared its bytes and source-set fingerprint with the reviewed snapshot; all matched. This report is added in a later documentation commit and excluded from its own source identity. Conclusions do not automatically extend to changes in reviewed files.

## Coverage

All tracked files at the reviewed SHA except this report: dispatcher, all command sources and helpers, both installers, website HTML/CSS/SVG and sitemap, all five workflows, Dependabot configuration, README, security policy, version, license, ignore configuration, AGENTS.md and review methodology. Ignored ai_docs and unrelated .DS_Store were excluded. Required local instruction file `/Users/maxim/work/skill-universe/AGENTS.local.md` was missing; no sibling instructions were substituted.

## Coverage and conclusions

| Item | Result | Source-based reasoning |
| --- | --- | --- |
| R01: undeclared communication | No issue identified | CLI communication is through requested Git operations. The [website](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/docs/index.html) has local executable JavaScript that copies the visible installation command on a click. Public GitHub/Scorecard badge images make external requests and disclose ordinary browser request metadata to those services; they are visible status resources, not executable dependencies. The [Scorecard workflow](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/.github/workflows/scorecard.yml) explicitly publishes repository-practice results. |
| R02: code injection | No issue identified | The [dispatcher](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/skill-universe) allowlists commands. Shell arguments are quoted and user/repository values enter jq through data parameters. Configurable Git URL operands use option separation. Skills and rules are linked, not evaluated or executed by the distributor. User-selected transports, Git hooks/configuration and executable tool upgrades remain trusted boundaries. |
| R03: path confinement | No issue identified | The [common helper](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/commands/common.sh) restricts names to ASCII letters, digits, dot, underscore and dash, rejecting empty names, dot and double-dot. Installation discovers immediate children of fixed source directories. Local manifest destinations must be absolute after explicit home expansion. Remove/rename require a registered entry and exact original symlink target; update resolves registered sources. |
| R04: source links | No issue identified | [Install](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/commands/install.sh) rejects symlinks in both the committed tree and current source directories, including nested resources and root skills/rules directories. [Update](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/commands/update.sh) validates the incoming tree and local sources before merging. Checkout parents are derived by the tool. Deliberate local state replacement and concurrent external edits remain local-user trust concerns. |
| R05: unrelated files | No issue identified | Install rejects occupied destinations, including dangling links. [Rename](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/commands/rename.sh) validates source identity and target availability, uses non-overwriting movement and verifies completion. Remove deletes the verified link. Manifest and managed AGENTS.md leaf symlinks are rejected. Both [bootstrap copies](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/install.sh) preflight destinations; failed bootstrap can leave a checkout or created directories but does not request unrelated-file replacement. |
| R06: personal instructions | No issue identified | The [managed-block helper](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/commands/codex-rules.sh) rejects duplicate/nested starts, unmatched ends and unterminated blocks before mutation. It preserves other content, stages replacement beside the destination, preserves existing permissions and renames into place. Callers back up AGENTS.md; a symlink at that file is rejected. |
| R07: updates and failure handling | No issue identified within documented guarantees | Mutating commands share an atomic directory lock, private transaction directory and backups marked ready only after completion. Ordinary failures and handled signals restore recorded file paths. [Update](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/commands/update.sh) and [upgrade](https://github.com/seliverstov-maxim/skill-universe/blob/06e488cfef9586197112bf0a37d5c6ce90e2b7b2/commands/upgrade.sh) use fast-forward-only merges with no autostash and no overwrite of ignored files. A pending Git marker retains recovery data on failed/interrupted merges. Each completed checkout update checkpoints manifest progress. There is no automatic destructive Git reset or claim of crash atomicity. |
| R08: executable trust | No issue identified under stated assumptions | Bootstrap trusts executable content served by GitHub Pages and clones the default branch. Upgrade defaults to mutable main; local configuration can change its source. This SHA does not attest to future delivered code. CI actions use full commit pins and Gitleaks uses an image digest. Runner tools and external action implementations are unaudited dependency assumptions. Linked skills/rules later influence Codex/Claude with those applications' permissions and are not sandboxed or certified. |

## Overall judgment and remaining boundaries

Under the stated trust assumptions, the source supports reasonable use as a small Git-backed distributor with local development and recoverable state. The fresh reviewer found no actionable defect or source question requiring correction. This is not proof of the absence of defects or hidden behavior.

- The local user controls arguments, manifest destinations, executable upgrade sources, and local Git configuration. This configuration has filesystem and Git authority by design.
- Repository authors control downloaded instruction content and future updates. Source names and symlinks are constrained; instruction intent is not certified.
- Bootstrap and upgrade publishers supply trusted executable code. Mutable delivery sources can change after this audit.
- The OS, shell, Git, jq, runner software and pinned third-party CI implementations are dependency assumptions, not audited implementations.
- Locks coordinate this tool's mutating commands, not arbitrary processes of the same OS account. Concurrent external modifications are outside isolation guarantees.
- SIGKILL, power loss, storage failures and failed Git operations can require the README's manual recovery procedure. Complete Git/filesystem atomicity is not claimed.
- Live GitHub settings, scanner results and Scorecard ratings are separate from this source audit. This assessment establishes no runtime, cross-platform, dependency, service-configuration or formal-verification result.

## Exact reviewed source

SHA-256 values identify file contents, not runtime behavior or permissions. The source-set fingerprint hashes sorted UTF-8 records formatted as `hash`, two spaces, relative path, newline. This report is excluded to avoid self-reference.

| File | SHA-256 |
| --- | --- |
| `.github/dependabot.yml` | `ee0eac6edd3fcb920c690fecefdc3e7ca2809c1e2ee39201aad4e386c0baca9e` |
| `.github/workflows/codeql.yml` | `cf7957c21d236b8ab6ac3e40f740b0fb560ee388b6894edf5066a47b5d43e6ca` |
| `.github/workflows/gitleaks.yml` | `09fea17727950fbbd20987885f9f5044b24783e2cb4d925f615ddbdf7c8ad40c` |
| `.github/workflows/scorecard.yml` | `e58fad827b18933f261058edca8e4961ff9112cdb99ea55b5ee2a816e03d9d7d` |
| `.github/workflows/shellcheck.yml` | `75164c11df02bef74ea4c295ad14a2ce3efb669340672d29e7b66c31fd697de5` |
| `.github/workflows/zizmor.yml` | `09d28a9f11d300de7c43b76b431a275f86a149bf34b79ce16b4ef635bfefa970` |
| `.gitignore` | `84011150a41ad4d1d6825e2934ae8809ce0545ebd1e85c558f5bbcd0b8da6510` |
| `AGENTS.md` | `43fc2142c49b48271cbdb92024a71de239e9de9027b4d0ed83f692a49d3026dc` |
| `LICENSE` | `f7c5fe99edbfc97154bac5152ce12bd8e6ab6dbecff33c0fedbf472e01fae7aa` |
| `README.md` | `bd0b4eadeb7027146a95d8afb66e085e119d0afa811b58e15c695403f847e124` |
| `SECURITY.md` | `b444b2bf519771946817a94f3308532c1fd8632537aab11dce69cb730e64d73f` |
| `VERSION` | `e9dd8507f4bf0c6f42458e41aea833ad0bd3f6127272335eee9bf4d58541ed67` |
| `commands/codex-rules.sh` | `baa67173546cac472d216af2a6b143f62174d3637ea02169ba17bdbd551bdb1e` |
| `commands/common.sh` | `851e4f2ccb13a6446e0ea98cd03b0f20e9e5e7ffcba0e82bc33de7dc95e961cd` |
| `commands/help.sh` | `d8c974da6bff82aeb41acf70f698d1eaf6a6d991529cf79e53331f24c0ecd7bc` |
| `commands/init.sh` | `6a8ca6423f6d8b4ede6d63d3ca103ed3ccbcb25eb0e7700dc123f510eb99e5ea` |
| `commands/install.sh` | `677067930a4b9a6cf8f02710ad72e4a9e810af649db2d647710f55be11a40ff4` |
| `commands/list.sh` | `9e6c21fa2fc8615aa2ea8f57c9180e2c50c7e0d75042510df1c868d6679bdd4d` |
| `commands/remove.sh` | `aa930fdd1058873e5e12db11a58f3cea0345b279b2e9348bf089e4804f0f03a4` |
| `commands/rename.sh` | `847082f63c7f3fe6f84518d1d4ae7e24371b3093ae57beede23e04dcceb4e046` |
| `commands/update.sh` | `363b052594c4f26516cf4ae525ff554e1482076f11ad9d963f10a7c579ccff22` |
| `commands/upgrade.sh` | `1eeebcc340aea5cd1ac4acabe854db7bab69fa3c6da98302de8be9eefa99f142` |
| `commands/version.sh` | `f8073966e183f2d5256310ab225cd1fcd33ebd552bfb0548bcbaaea79ff91d78` |
| `docs/icon.svg` | `4caf6a04bceea2ed9b32a60300831df0210e4fd7a8bd8afd047fd3bc1f72ef98` |
| `docs/index.html` | `8565419cd479a60f41cb35425e9ae477a8c3237cc084021f310150806407b71e` |
| `docs/install.sh` | `aa0c12916ffdc8e0d416f263a077ba2f831ecf9f2e96e0516e2f4bd371439d52` |
| `docs/security/methodology.md` | `2e637350db9061a89bcd186865459fc9ea56fa35aa26b77d249b91b8e2926fc4` |
| `docs/sitemap.xml` | `7e1bee0bfcdb32c30705ec7d5a611f343263fe2af68a4b6ea688a40e890394e1` |
| `docs/style.css` | `81b13e0f42fbce0eb843a899fa27a65930ae0cafe0094aa6c11029b3e92c661a` |
| `install.sh` | `aa0c12916ffdc8e0d416f263a077ba2f831ecf9f2e96e0516e2f4bd371439d52` |
| `skill-universe` | `df952232f6c1fe9eccd8ca5f12a48c27f4c3768e11bc21bd98cc3ea852edc47a` |

## Repeat or challenge the review

Anyone can repeat this source review by reading the exact commit above and following the published methodology in a fresh context. Do not give the reviewer this assessment or previous findings before its review. Record evidence-based disagreements and replace this report when a new assessment is completed. No test runner or scanner is required.
