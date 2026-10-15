# Declared behavior review

Procedure: **SU-DECL-1, version 1**. An additional part of the internal source audit: compare implemented behavior with public requirements and look for undeclared actions.

Use the same frozen commit, complete file coverage and fresh-context reviewer as [SU-SEC-1](methodology.md). The declarations are the README, CLI help and website at that exact commit; identify conflicting or ambiguous claims rather than silently choosing one. Include installers, failure paths, website code, development scripts and CI, distinguishing their effects from the installed CLI.

For each question, publish **Yes** or **No** in `docs/security/declared-behavior-report.md`, with a short explanation and immutable links to both the declaration and implementation. For questions covering several commands or promises, check each one; one unsupported promise makes the answer No. If the evidence cannot establish compliance, answer No and explain whether this is a mismatch or insufficient evidence. For Q12, answer No only after reading the complete scoped source; uncertainty must remain explicit in the explanation.

## Questions

| ID | Question |
| --- | --- |
| Q01 | Does every documented command, flag and default have a corresponding implementation with the declared behavior? |
| Q02 | Do init, manifest configuration and harness selection behave as declared for Codex and Claude? |
| Q03 | Does installation discover and select skills/rules, handle branches and aliases, and create symlinks according to the documented repository structure and naming rules? |
| Q04 | Do list, rename and remove operate on the declared registered items and preserve unrelated files and personal instructions as promised? |
| Q05 | Do update and upgrade use the declared sources and sharing behavior, preserve local edits, and obey the documented Git merge restrictions? |
| Q06 | Do file destinations, managed AGENTS.md changes, caches, locks, backups and recovery behavior match the documented side effects and limits, including failure paths? |
| Q07 | Are CLI and installer network operations limited to their declared purposes and user-selected sources, with no identified telemetry, rankings, external catalog or background requests? |
| Q08 | Does the distributor avoid executing downloaded skill/rule payloads, and accurately state the trust placed in bootstrap, upgrades and consuming agents? |
| Q09 | Do dependencies, platform claims, requested permissions and credential handling match the documented scope without additional runtime services or privilege elevation? |
| Q10 | Are website network requests and browser actions consistent with visible features and declarations, without identified hidden collection or external executable code? |
| Q11 | Do development scripts, CI and badges perform only their stated checks/publication, with audit coverage and limitations represented accurately? |
| Q12 | Did the complete source review identify any additional behavior or side effect absent from, or conflicting with, the declarations? |

## Repeating the review

Read the same declarations and complete source at the report's full commit SHA, in a fresh context without previous answers. Trace each question through normal and failure paths; record your own Yes/No answers and source evidence before comparing reports. List every mismatch or undeclared action, including documentation-only defects, for correction and fresh review.

Reproducible means another reviewer can inspect the same evidence and challenge the answers. Source reading does not prove the absence of hidden behavior, validate runtime/platform behavior, or audit dependencies. No test suite or scanner is part of this procedure.

## Report result

State `- Result: **passing**`, `failing` or `incomplete`. Passing requires Q01–Q11 Yes, Q12 No, and no unresolved evidence or mismatches. A confirmed mismatch or undeclared behavior means failing; an unfinished review or insufficient evidence means incomplete. A No for Q12 means no undeclared behavior was identified in the scoped review, not proof that none can exist. Use the source inventory and output exclusions defined in SU-SEC-1; publish only the latest report for this methodology.
