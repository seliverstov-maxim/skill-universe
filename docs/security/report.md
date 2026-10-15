# Security review

- Judgment: **No actionable security or correctness findings identified in the final fresh-context source review, within the stated scope and trust model.**
- Status: **Completed source review; committed files match the independently reviewed snapshot.**
- Reviewed commit: [`9f6b598ba45b76a632d2e4539950e791f899a13b`](https://github.com/seliverstov-maxim/skill-universe/tree/9f6b598ba45b76a632d2e4539950e791f899a13b).
- Exact source identity: per-file SHA-256 hashes below; source-set SHA-256 `403a5099d11ac4f496d4f7949eac6f8423c7c6a89038539f4ea302b36ba0eee1`.
- Date: 2026-10-15
- Reviewers: Codex in four separate fresh contexts; fixes applied by the implementing agent. Context separation does not make this an independent organization audit.
- Procedure: [SU-SEC-1, version 3](methodology.md). The unchanged R01–R08 checklist was applied with the maintainer-requested clean-context draft workflow now documented in this version.

This is the single current report. The implementing agent read every covered committed file and compared its SHA-256 with the frozen snapshot reviewed by the final fresh-context agent; all matched. This report and methodology are published in a later documentation commit. The subsequently added OpenSSF workflow and README badge are outside this application-source review; their external result is separate from this assessment. Conclusions do not automatically extend to later revisions.

## Review process and outcome

Each reviewer received the source location, intended behavior and checklist in a new context, without the implementation conversation. Reviewers were instructed not to read this report, local review notes, Git history/diffs or earlier findings. Application source stayed unchanged during each pass.

The first pass identified potential overwriting of ignored local files by Git updates; guarded merges now refuse that overwrite. The second found successful installation when an explicit selector matched nothing; that now fails. The third found omission of valid dot-prefixed item names; discovery now includes them. The fourth read the complete resulting source and identified no actionable finding.

Earlier path, collision, source-link and managed-block concerns are addressed by the controls below. State operations now have serialization, backups, rollback and explicit Git recovery handling. This is a source-based assessment, with no runtime, cross-platform, scanner, or test results offered as security evidence.

## Coverage and conclusions

Read completely: dispatcher; all eleven `commands/*.sh` files including the shared helper; both installers; README and VERSION; full website HTML, CSS, SVG and sitemap; and the review checklist. Published/local review reports and unrelated files were excluded from reviewer input. The required project file `/Users/maxim/work/skill-universe/AGENTS.local.md` was absent; no sibling project's instructions were substituted.

| Item | Result | Source-based reasoning |
| --- | --- | --- |
| R01: undeclared communication | No issue identified | [Install](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/commands/install.sh), [update](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/commands/update.sh) and [upgrade](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/commands/upgrade.sh) use explicit Git sources. [Website](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/docs/index.html) resources are local; its active script only copies the displayed command after a click. No telemetry sender or additional executable resource was identified. |
| R02: code injection | No issue identified | [Dispatcher](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/skill-universe) accepts a fixed command set. Shell arguments are quoted, jq input values use data parameters, and downloaded skills/rules are linked rather than executed. Shared code is loaded from the tool's own source directory. |
| R03: path confinement | No issue identified | [Common helper](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/commands/common.sh) restricts names to single safe components. Remove/rename require registered entries and symlinks matching the recorded source before mutation. Selectors only filter immediate discovered entries. |
| R04: source links | No issue identified | Install rejects symlinks anywhere under skills/rules, including root directories and nested resources. Update validates the incoming Git tree and existing local resources before merge. Installer-created delivery symlinks are distinct from prohibited source links. |
| R05: unrelated files | No issue identified | Install, rename and [bootstrap](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/install.sh) reject occupied destinations, including directories and dangling links. Rename uses no-overwrite behavior. Files and links affected by state commands have backups; substituted installed paths are rejected. |
| R06: personal instructions | No issue identified | [Block helper](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/commands/codex-rules.sh) rejects unbalanced, repeated or nested markers and symlinked AGENTS.md. Content is prepared separately and replaced without truncating the original first; removal applies only to a validated block. |
| R07: updates and failure handling | No issue identified within documented guarantees | Mutating commands share a lock and private transaction directory; ordinary failures trigger file rollback. Git merges explicitly use fast-forward-only, no automatic stash and no overwrite of ignored files. Each successful checkout update checkpoints manifest state. Failed/interrupted Git changes retain recovery information rather than automatically resetting development files. |
| R08: executable trust | No issue identified within stated trust model | Bootstrap and upgrade deliberately trust the selected executable source. The README discloses mutable updates, trusted dependencies, instruction trust and recovery limits. The reviewed commit is distinguished from mutable source branches. |

The ignored-file behavior and its guard are documented in [Git's merge options](https://git-scm.com/docs/git-merge#Documentation/git-merge.txt---no-overwrite-ignore).

## Remaining boundaries

- The OS, shell, Git, jq and local executable/configuration environment are trusted dependencies, not audited implementations.
- Skills and rules can instruct an agent to take unsafe actions. The tool distributes them; it does not sandbox or certify their contents.
- Bootstrap and upgrades can obtain future code that differs from this reviewed revision.
- The lock coordinates Skill Universe's mutating commands, not arbitrary processes of the same OS account. Concurrent external edits are outside its isolation guarantee.
- SIGKILL, power loss and storage failure cannot guarantee an automatic rollback. Retained backups/lock and the [README recovery procedure](https://github.com/seliverstov-maxim/skill-universe/blob/9f6b598ba45b76a632d2e4539950e791f899a13b/README.md#file-safety-and-recovery) support manual reconciliation; complete Git/filesystem crash atomicity is not claimed. Failed Git merges, including ordinary conflicts, deliberately retain recovery state.
- Static reading can miss defects. No actionable finding means none was identified in this review, not proof that none can exist. Syntax checking performed during implementation is not a security certification.

## Exact reviewed source

SHA-256 values identify file contents, not runtime behavior or file permissions. The source-set fingerprint hashes the UTF-8 concatenation of sorted lines `hash`, two spaces, relative path, newline. Review methodology and this report are procedure/output documents, outside that application-source fingerprint.

| File | SHA-256 |
| --- | --- |
| `README.md` | `1825e80842d5a675f72aa562be60379616e465a555196f49d585261b24e7b169` |
| `VERSION` | `e9dd8507f4bf0c6f42458e41aea833ad0bd3f6127272335eee9bf4d58541ed67` |
| `commands/codex-rules.sh` | `be90e2f7ab30d6db6d5777b9e5607ce2db69f92021388fca556887d1d5551fac` |
| `commands/common.sh` | `ce9574d7341dcc29a6655416bc3ee83bab6f9598aef8376c9c779f1a08d951b1` |
| `commands/help.sh` | `d8c974da6bff82aeb41acf70f698d1eaf6a6d991529cf79e53331f24c0ecd7bc` |
| `commands/init.sh` | `6a8ca6423f6d8b4ede6d63d3ca103ed3ccbcb25eb0e7700dc123f510eb99e5ea` |
| `commands/install.sh` | `faadde4272c5c8dfc6683d94bc41b38816bc813e6ee8d73929f35ebcd4db2832` |
| `commands/list.sh` | `9e6c21fa2fc8615aa2ea8f57c9180e2c50c7e0d75042510df1c868d6679bdd4d` |
| `commands/remove.sh` | `aa930fdd1058873e5e12db11a58f3cea0345b279b2e9348bf089e4804f0f03a4` |
| `commands/rename.sh` | `847082f63c7f3fe6f84518d1d4ae7e24371b3093ae57beede23e04dcceb4e046` |
| `commands/update.sh` | `8453f8f4c1aa452291eefee2232b11152704f07ec6af036dad6dec11edfd8c21` |
| `commands/upgrade.sh` | `1eeebcc340aea5cd1ac4acabe854db7bab69fa3c6da98302de8be9eefa99f142` |
| `commands/version.sh` | `f8073966e183f2d5256310ab225cd1fcd33ebd552bfb0548bcbaaea79ff91d78` |
| `docs/icon.svg` | `4caf6a04bceea2ed9b32a60300831df0210e4fd7a8bd8afd047fd3bc1f72ef98` |
| `docs/index.html` | `5d5d9fb0f89089e1a30f909b9914f11628e092a3792e43d7eb36bb46836f58eb` |
| `docs/install.sh` | `be102e35885cd46a097955e6f3b02361635f523183d40baa520c79a5c65c0ef1` |
| `docs/sitemap.xml` | `7e1bee0bfcdb32c30705ec7d5a611f343263fe2af68a4b6ea688a40e890394e1` |
| `docs/style.css` | `9b8e57751dc34ac621219db752a8e5fc570da9e8386953d3391924668986ee13` |
| `install.sh` | `be102e35885cd46a097955e6f3b02361635f523183d40baa520c79a5c65c0ef1` |
| `skill-universe` | `df952232f6c1fe9eccd8ca5f12a48c27f4c3768e11bc21bd98cc3ea852edc47a` |

## Repeat or challenge the review

Follow [the methodology](methodology.md) in a fresh context, identify this exact source snapshot (or a new full commit SHA), and read all covered files. Do not give the reviewer the findings above before it completes its own assessment. Replace this report if source evidence changes the conclusion. No test runner or scanner is required.
