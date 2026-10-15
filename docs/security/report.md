# Security review

- Judgment: **No actionable security or correctness findings identified in the final fresh-context source review, within the stated scope and trust model.**
- Status: **Completed source review; committed files match the independently reviewed snapshot.**
- Reviewed commit: [`c3fb81551663384728bfdcaaf2d9c5fada36ce5f`](https://github.com/seliverstov-maxim/skill-universe/tree/c3fb81551663384728bfdcaaf2d9c5fada36ce5f).
- Exact source identity: per-file SHA-256 hashes below; source-set SHA-256 `74c0eeecfe717f9734dea1e6f1fc729ed24d943e65d3991bf953d4c2087a9041`.
- Date: 2026-10-15
- Reviewers: a fresh-context Codex source reviewer, separate from the implementing agent. This is AI-assisted review, not independent institutional certification.
- Procedure: [SU-SEC-1, version 3](methodology.md).

This is the single current report. The implementing agent read every covered committed file and compared its SHA-256 with the final fresh-context reviewer's snapshot; all matched. The report is necessarily added in a later documentation commit. It covers the CLI, installers, website code, security policy and workflow configuration at the stated SHA. Live GitHub settings and the external Scorecard rating are separate assessments; conclusions do not automatically extend to later revisions.

## Review process and outcome

The reviewer received the source location, intended behavior and methodology without the implementation conversation. It did not read prior reports, local review notes, Git history/diffs or other reviewers' findings. Source stayed unchanged throughout the final pass. The reviewer identified no actionable security or correctness finding under the stated trust model.

The implementation now also has a private-reporting policy with email fallback, weekly GitHub Actions dependency-update proposals, and a read-only ShellCheck workflow for main pushes and pull requests. ShellCheck annotations are confined to known literal strings and the shared module's caller-provided inputs/outputs; no blanket repository suppression was introduced. Explicit equivalent if statements keep the checks readable across analyzer versions.

The source assessment itself used no tests, scanners, or runtime execution. Separately, the implementing agent confirmed the configured ShellCheck invocation passes with version 0.9.0, matching the selected GitHub runner, without executing the CLI or installer. That lint result is a development check, not proof of application safety.

## Coverage and conclusions

Read completely: dispatcher; all eleven command sources; both installers; README, SECURITY.md and VERSION; the Dependabot configuration; both GitHub workflows; active HTML and referenced CSS/SVG; methodology. The current report, ai_docs, history/diffs and unrelated metadata were excluded from reviewer input. Required project file `/Users/maxim/work/skill-universe/AGENTS.local.md` was absent; no sibling instructions were substituted.

| Item | Result | Source-based reasoning |
| --- | --- | --- |
| R01: undeclared communication | No issue identified | [Install](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/commands/install.sh), [update](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/commands/update.sh) and [upgrade](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/commands/upgrade.sh) use explicit Git sources. [Website](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/docs/index.html) resources are local; its active script only copies the displayed command after a click. No runtime telemetry sender or additional executable website resource was identified. Scorecard publication is an explicit development workflow. |
| R02: code injection | No issue identified | [Dispatcher](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/skill-universe) accepts a fixed command set. Shell arguments are quoted, jq input values use data parameters, and downloaded skills/rules are linked rather than executed. Shared code is loaded from the tool's own source directory. |
| R03: path confinement | No issue identified | [Common helper](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/commands/common.sh) restricts names to single safe components. Remove/rename require registered entries and symlinks matching the recorded source before mutation. Selectors only filter immediate discovered entries. |
| R04: source links | No issue identified | Install rejects symlinks anywhere under skills/rules, including root directories and nested resources. Update validates the incoming Git tree and existing local resources before merge. Installer-created delivery symlinks are distinct from prohibited source links. |
| R05: unrelated files | No issue identified | Install, rename and [bootstrap](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/install.sh) reject occupied destinations, including directories and dangling links. Rename uses no-overwrite behavior. Files and links affected by state commands have backups; substituted installed paths are rejected. |
| R06: personal instructions | No issue identified | [Block helper](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/commands/codex-rules.sh) rejects unbalanced, repeated or nested markers and symlinked AGENTS.md. Content is prepared separately and replaced without truncating the original first; removal applies only to a validated block. |
| R07: updates and failure handling | No issue identified within documented guarantees | Mutating commands share a lock and private transaction directory; ordinary failures trigger file rollback. Git merges explicitly use fast-forward-only, no automatic stash and no overwrite of ignored files. Each successful checkout update checkpoints manifest state. Failed/interrupted Git changes retain recovery information rather than automatically resetting development files. |
| R08: executable trust | No issue identified within stated trust model | Bootstrap and upgrade deliberately trust the selected executable source. The README discloses mutable updates, trusted dependencies, instruction trust and recovery limits. The reviewed commit is distinguished from mutable source branches. |

The ignored-file behavior and its guard are documented in [Git's merge options](https://git-scm.com/docs/git-merge#Documentation/git-merge.txt---no-overwrite-ignore).

## Remaining boundaries

- The OS, shell, Git, jq and local executable/configuration environment are trusted dependencies, not audited implementations.
- Skills and rules can instruct an agent to take unsafe actions. The tool distributes them; it does not sandbox or certify their contents.
- Bootstrap and upgrades can obtain future code that differs from this reviewed revision.
- The lock coordinates Skill Universe's mutating commands, not arbitrary processes of the same OS account. Concurrent external edits are outside its isolation guarantee.
- SIGKILL, power loss and storage failure cannot guarantee an automatic rollback. Retained backups/lock and the [README recovery procedure](https://github.com/seliverstov-maxim/skill-universe/blob/c3fb81551663384728bfdcaaf2d9c5fada36ce5f/README.md#file-safety-and-recovery) support manual reconciliation; complete Git/filesystem crash atomicity is not claimed. Failed Git merges, including ordinary conflicts, deliberately retain recovery state.
- Static reading can miss defects. No actionable finding means none was identified in this review, not proof that none can exist. Syntax checking performed during implementation is not a security certification.

## Exact reviewed source

SHA-256 values identify file contents, not runtime behavior or permissions. The source-set fingerprint hashes the UTF-8 concatenation of sorted lines `hash`, two spaces, relative path, newline. The methodology is included as reviewed procedure input; this report is excluded to avoid self-reference.

| File | SHA-256 |
| --- | --- |
| `.github/dependabot.yml` | `eada67e1b7f73d16a4c240ede6193c4852a2b0887e678a23dc7a3462810502e7` |
| `.github/workflows/scorecard.yml` | `f76eddbfef6fbdd8bac4d9f2aeb7928b39a06ffbeb24f0d852296e11bb111577` |
| `.github/workflows/shellcheck.yml` | `75164c11df02bef74ea4c295ad14a2ce3efb669340672d29e7b66c31fd697de5` |
| `README.md` | `ad6fbd8551b5c7bc68e0157b00a752ecd2873f6cfd03437e177eb2f4ef304f01` |
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
| `docs/index.html` | `5d5d9fb0f89089e1a30f909b9914f11628e092a3792e43d7eb36bb46836f58eb` |
| `docs/install.sh` | `aa0c12916ffdc8e0d416f263a077ba2f831ecf9f2e96e0516e2f4bd371439d52` |
| `docs/security/methodology.md` | `2e637350db9061a89bcd186865459fc9ea56fa35aa26b77d249b91b8e2926fc4` |
| `docs/style.css` | `9b8e57751dc34ac621219db752a8e5fc570da9e8386953d3391924668986ee13` |
| `install.sh` | `aa0c12916ffdc8e0d416f263a077ba2f831ecf9f2e96e0516e2f4bd371439d52` |
| `skill-universe` | `df952232f6c1fe9eccd8ca5f12a48c27f4c3768e11bc21bd98cc3ea852edc47a` |

## Repeat or challenge the review

Follow [the methodology](methodology.md) in a fresh context, identify this exact source snapshot (or a new full commit SHA), and read all covered files. Do not give the reviewer the findings above before it completes its own assessment. Replace this report if source evidence changes the conclusion. No test runner or scanner is required.
