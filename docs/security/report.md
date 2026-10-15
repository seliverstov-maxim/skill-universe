# Internal source audit

- Procedure: [SU-SEC-1 version 3](methodology.md).
- Date: 2026-10-15.
- Reviewed by Codex at [`2fe9b62ee76ec29f841bbea0fd189506e4a58a21`](https://github.com/seliverstov-maxim/skill-universe/tree/2fe9b62ee76ec29f841bbea0fd189506e4a58a21).
- Reviewer role: fresh source-review agent, without inherited implementation conversation, previous reports, diffs/history or other reviewers' conclusions. This agent did not implement the reviewed changes. This is an agent review, not independent institutional certification.
- Root instructions: read root AGENTS.md and committed docs/security/methodology.md completely. `/Users/maxim/work/skill-universe/AGENTS.local.md` is missing; no substitute from another directory was used.
- Scope: completely read all 33 tracked files at the reviewed revision except docs/security/report.md and generated docs/security/audit.svg. Ignored ai_docs and unrelated .DS_Store are excluded. Read committed bytes through git show at the exact SHA, starting with dispatcher, commands/helpers, installers and then website, documentation and workflows. No repository code, tests, scanner, installer or CLI was executed. A separate local bookkeeping operation calculated SHA256 from committed file bytes; it was not a security scanner.
- Source fingerprint: `04301260fee09653e722a4502c38b6b43d779dd08ad2e6f757a3023c356e4e4b`, calculated as SHA256 of sorted concatenated UTF-8 records `hash + '  ' + path + '\n'` for the inventory below.

This is the single current report. Before publishing it, the implementing agent compared every scoped committed file and current working file with the fresh reviewer's 33-file hash inventory; all matched. This report and its generated badge are later documentation outputs and are excluded from the reviewed source identity to avoid circular hashes.

## Findings and judgment

No actionable security concern identified in the scoped source under the stated assumptions. The tool is reasonable to use when the user trusts the bootstrap/upgrade source, local manifest/configuration and installed instruction authors, and when user-owned parent directories are not being maliciously replaced concurrently. Installed skills/rules have the consuming agent's permissions and are not sandboxed. This conclusion does not extend to arbitrary third-party instructions, mutable future source, dependencies, runtime or cross-platform behavior.

The badge identifies a reviewed source revision and links to a report; the generator and CI establish inventory/hash/output agreement only. They cannot prove that a human or agent actually performed the audit or that the report's conclusions are true.

## Trust boundaries and data flows

The user chooses CLI arguments and edits the local manifest, harness destinations and upgrade source. A repository author controls fetched checkout paths/content, skill names, rules and incoming Git trees. Bootstrap and upgrade sources supply executable CLI code. Git, jq, shell, OS, Git transport/configuration, Python for development tooling and workflow actions are trusted dependencies outside this source review. Codex/Claude interpret linked instructions with their own permissions.

Git URLs/branches flow to explicitly requested Git operations and checkout IDs; selectors/aliases flow through name validation before install/remove/rename paths. Repository paths flow through symlink validation before links become visible. Local manifest destinations are explicitly configurable absolute paths, not remote-controlled values. Manifest mutations use jq arguments and private transaction files. State-changing commands share one directory lock, retain file backups and handle ordinary failures/signals. Git updates retain recovery state rather than attempting a destructive reset. The website's only active browser operation copies fixed installation text after a user click; external badge requests expose ordinary browser request metadata to the displayed status providers. CI intentionally publishes Scorecard results; this is separate from CLI user activity.

## Checklist

### R01 — No issue identified

[CLI dispatcher](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/skill-universe), [install](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/install.sh), [update](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/update.sh) and [upgrade](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/upgrade.sh) contain requested Git operations and local output, with no additional runtime telemetry destination. [Website](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/docs/index.html) loads local CSS/icon/audit SVG plus remote GitHub and Scorecard status images; it loads no external executable resources. JSON-LD is data, and the inline click handler copies fixed text through the clipboard API. [Scorecard CI](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/.github/workflows/scorecard.yml) explicitly publishes project scan results. External badge/CI services are expected disclosed integrations, not CLI secret-exfiltration paths.

### R02 — No issue identified

[Dispatcher](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/skill-universe) uses an exact command allowlist, then quoted arguments to sh. [Install](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/install.sh) and [update](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/update.sh) quote URLs, branches and paths and terminate Git options before repository operands. jq programs remain constant and receive values through --arg. There is no eval or downloaded payload execution during skill/rule installation. The [Python generator](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/scripts/generate-audit-badge.py) uses subprocess argv lists and a 40-character lowercase hexadecimal revision, not shell command interpolation. User-controlled Git URLs/protocols and local Git filters/hooks/configuration belong to the documented local-input/dependency boundary; this is not a remote-repository-only execution finding.

### R03 — No issue identified

[Common validation](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/common.sh) rejects empty names, dot/dot-dot and characters outside ASCII letters/digits/dot/underscore/dash. [Install](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/install.sh) validates explicit selectors and aliases and validates discovered names before destination creation. [Remove](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/remove.sh) and [rename](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/rename.sh) select registered manifest entries and require the existing link's exact computed target. Leading dashes cannot become destination options because operands are absolute constructed paths. Manifest destinations may intentionally point outside default harness locations; only the user controls this configuration.

### R04 — No issue identified

[Common helpers](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/common.sh) reject a source that is itself a symlink and recursively reject nested links; tree_ok rejects incoming Git mode 120000 under skills/rules. [Install](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/install.sh) checks top-level skills/rules parents and selected sources before linking. [Update](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/update.sh) checks the complete candidate tree before merge and checks existing source parents. This covers repository-controlled enclosing directories and nested resources. The user's checkout/state parent directories and later direct local modifications remain trusted local state.

### R05 — No issue identified

[Install](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/install.sh) and [rename](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/rename.sh) reject occupied destinations, including dangling symlinks; rename additionally uses mv -n and verifies the old link moved. Remove/rename require exact registered links. [Common](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/common.sh) rejects manifest symlinks, backs up files/links and restores on failure. [Both](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/install.sh) [installers](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/docs/install.sh) refuse occupied final checkout/command destinations. [AGENTS editor](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/codex-rules.sh) refuses destination symlinks and stages replacement beside the target. These controls do not claim protection against a hostile same-user process concurrently replacing user-owned parent directories.

### R06 — No issue identified

[AGENTS editor](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/codex-rules.sh) validates exact managed marker lines with awk before any write: duplicate starts, orphan ends and unterminated blocks fail. Adding an existing valid block is a no-op; otherwise personal bytes are copied before appending. Removing uses the exact validated marker range and leaves surrounding personal text. Existing mode is copied to a sibling temporary file before replacement, and caller transactions back up AGENTS.md. The local configured rules directory is instruction text from a trusted user setting.

### R07 — No issue identified

[Update](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/update.sh) and [upgrade](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/upgrade.sh) use fast-forward-only merges, refuse ignored-file overwrite and disable automatic stashing; neither uses reset/clean. [Common](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/common.sh) creates a lock atomically, private mktemp transaction directories and per-path backups; ordinary failures/signals roll back file mutations. git-pending is written before merge; failed/interrupted Git mutations retain lock/backups with recovery information. update all checkpoints manifest progress after each successful checkout, avoiding rollback of already-completed Git progress. Cache clones/new empty directories may remain after failure; forced termination/power loss and installer partial completion require manual recovery and are not claimed atomic. [README](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/README.md) documents these limits and safe recovery guidance.

### R08 — No issue identified

[Bootstrap](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/install.sh) trusts the fetched shell installer and upstream clone; [init](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/init.sh) explicitly sets upgrade to upstream main, and [upgrade](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/commands/upgrade.sh) trusts the locally configured source. A mutable branch is not covered by this immutable assessment. [Methodology](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/docs/security/methodology.md), README and SECURITY distinguish trusted dependencies/instruction authors and review limits. [Generator](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/scripts/generate-audit-badge.py) requires a full reviewed SHA, compares the complete tracked inventory excluding report/badge, checks committed and working bytes against per-file hashes, and emits a short SHA label/full SHA title. [Consistency CI](https://github.com/seliverstov-maxim/skill-universe/blob/2fe9b62ee76ec29f841bbea0fd189506e4a58a21/.github/workflows/internal-audit.yml) fetches history and invokes --check with read-only contents permissions and credentials persistence disabled. Coverage, source hash and generated badge mismatches produce failure. Report/badge text and methodology expressly describe consistency checks as distinct from performing/proving the audit. Actions are pinned by immutable SHA/digest; their implementations remain dependencies outside this review.

## Limits

These are source-based conclusions, not observed runtime outcomes. Reading source may miss defects and does not establish absence of hidden behavior. No test/scanner/CI result was treated as passing or as audit evidence. There is no dependency audit, formal verification, cross-platform validation, certification, guarantee about future updates or assessment of third-party instruction safety. Missing AGENTS.local.md remains an explicit instruction-availability limitation.

## File coverage

| File | SHA256 |
| --- | --- |
| `.github/dependabot.yml` | `ee0eac6edd3fcb920c690fecefdc3e7ca2809c1e2ee39201aad4e386c0baca9e` |
| `.github/workflows/codeql.yml` | `cf7957c21d236b8ab6ac3e40f740b0fb560ee388b6894edf5066a47b5d43e6ca` |
| `.github/workflows/gitleaks.yml` | `09fea17727950fbbd20987885f9f5044b24783e2cb4d925f615ddbdf7c8ad40c` |
| `.github/workflows/internal-audit.yml` | `2406e1e97866fc85535e6804de4b89b00301b3fff2a9652f00feb0483211a372` |
| `.github/workflows/scorecard.yml` | `e58fad827b18933f261058edca8e4961ff9112cdb99ea55b5ee2a816e03d9d7d` |
| `.github/workflows/shellcheck.yml` | `75164c11df02bef74ea4c295ad14a2ce3efb669340672d29e7b66c31fd697de5` |
| `.github/workflows/zizmor.yml` | `09d28a9f11d300de7c43b76b431a275f86a149bf34b79ce16b4ef635bfefa970` |
| `.gitignore` | `84011150a41ad4d1d6825e2934ae8809ce0545ebd1e85c558f5bbcd0b8da6510` |
| `AGENTS.md` | `97932eee3937b24c25d3e2c4e6e81914b149d8f309712bcac8555cb604df6b1e` |
| `LICENSE` | `f7c5fe99edbfc97154bac5152ce12bd8e6ab6dbecff33c0fedbf472e01fae7aa` |
| `README.md` | `6372dcdc8becfb693d34fbfabea0f190f6f0a70f17149779fba90679332423e3` |
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
| `docs/index.html` | `456613a912573176d717b5bea0c5ef3a2da9c26b50302f12c561d1b57fbcfc3d` |
| `docs/install.sh` | `aa0c12916ffdc8e0d416f263a077ba2f831ecf9f2e96e0516e2f4bd371439d52` |
| `docs/security/methodology.md` | `5b7a735cd8ce6851a341f0dec7a40ee7de56259c554ed24326c565ce353aaffd` |
| `docs/sitemap.xml` | `7e1bee0bfcdb32c30705ec7d5a611f343263fe2af68a4b6ea688a40e890394e1` |
| `docs/style.css` | `fa74efca1ca5d979ef7be688eeaa9b7a96be3fd5f642ba5c1acdf55a0c1f33cf` |
| `install.sh` | `aa0c12916ffdc8e0d416f263a077ba2f831ecf9f2e96e0516e2f4bd371439d52` |
| `scripts/generate-audit-badge.py` | `454172b7caf19c5aa73f4ba8883a1538917417dc2cd0271207e6537087b91857` |
| `skill-universe` | `df952232f6c1fe9eccd8ca5f12a48c27f4c3768e11bc21bd98cc3ea852edc47a` |
