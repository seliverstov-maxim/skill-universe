# Declared behavior review

Procedure: **SU-DECL-1, version 3**. A project-maintained comparison of implemented and observed behavior with public requirements, including a search for undeclared effects. It is not external certification or proof that no hidden behavior exists.

Use the same frozen commit, fresh source-review context, complete source inventory, bounded manual observations, result rules and four output exclusions as [SU-SEC-1](methodology.md). Declarations are this commit's README, CLI help, website and public verification/workflow documentation. Conflicting or ambiguous claims are findings, not permission to select the convenient interpretation.

## Questions

| ID | Question |
| --- | --- |
| Q01 | Does every documented command, flag and default have the declared implementation, with the documented manual command scenarios producing the expected results? |
| Q02 | Do init, manifest configuration, environment overrides and harness selection behave as declared for Codex and Claude? |
| Q03 | Does installation follow the documented structure, branch/selector/alias rules and symlink delivery behavior? |
| Q04 | Do list, rename and remove act on registered items and preserve unrelated files and personal instructions as promised? |
| Q05 | Do update and upgrade use the declared sources/sharing behavior, preserve local edits and follow the documented merge restrictions? |
| Q06 | Do file destinations, manual Codex setup instructions, caches, locks, backups and recovery match declared effects and limits, without editing personal instruction/configuration files, including the exercised failure scenarios? |
| Q07 | Are CLI/installer network operations limited to declared purposes and user-selected sources, without identified telemetry, rankings, catalogs or background requests? |
| Q08 | Does distribution avoid executing skill/rule payloads and correctly disclose executable bootstrap/upgrade and consuming-agent trust? |
| Q09 | Do dependencies, platform scope, permissions and credential handling match the declarations, with no identified extra runtime service or privilege requirement? |
| Q10 | Are the website's delivered resources, visible actions and network destinations consistent with their declarations, without identified hidden collection or external executable code? |
| Q11 | Do development scripts, CI, report pages and badges perform only their stated checks/publication and represent their limits accurately? |
| Q12 | Did complete source review or the recorded observations identify any undeclared or contradictory behavior or side effect? |
| Q13 | Does the real site's installation link resolve to the declared installer bytes and Git destination, with effective URLs/revisions, mutable sources and secondary downloads accounted for? |

## Current report

Write `declared-behavior-report.json` using [report-format.md](report-format.md). Each row contains **Yes/No**, Code review, Observed result, short source/observation evidence and limits. Q01–Q11 and Q13 expect Yes; Q12 expects No. One unsupported promise makes its positive answer No. Insufficient evidence must be explicit and results incomplete, never converted to a confident No-hidden-behavior conclusion.

Passing requires the expected answers, source checks passed, required bounded observations completed, and no open mismatch or unresolved evidence within the recorded scope. No for Q12 means no undeclared behavior was identified in that scoped assessment; it is not a mathematical absence claim. Clipboard interaction, every possible input, other platforms and live consuming-agent behavior must not be represented as exercised if they were not.

For reproduction, independently follow [the repository prompt](review-prompt.txt) at latest fetched main or the exact recorded commit, read all scoped source, then perform the documented disposable scenarios and live read-only delivery check. Record your own answers before reading previous results. List mismatches, documentation defects and disagreements for correction and fresh review.

Before deployment, Q13 may remain incomplete if the real site serves an older installer. Record both revisions/hashes explicitly, with candidate delivery Not checked; do not reinterpret that as Passed. Complete the observation after publication.
