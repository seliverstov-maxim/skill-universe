# Internal audit result data

The static page, preamble, methodologies and reproduction prompt are source-controlled instructions. Each methodology has one current JSON result: `security-report.json` or `declared-behavior-report.json`. They are data, never executable HTML.

Fields: `method`, numeric `version`, full `commit`, UTC `date`, `result` (passing/failing/incomplete), actual `environment`, disclosed `reviewer` roles, `checks`, `observations`, and `files` (relative source path → SHA-256).

Each check contains `id`, `question`, `code` (passed/failed/not-checked), `observed` (passed/failed/not-checked/not-applicable), a short `note` stating evidence and limits, and `evidence` links with `label` and `url`. SU-DECL-1 also records `answer` (Yes/No). Observations contain `scenario`, actual `result` and concise `details`: command/exit/output/path facts, not internal reasoning or conversation. Record a read-only delivery observation with timestamp, effective URL, hashes and declared remote HEAD. Record any local Git URL redirection used in fixtures; it is not evidence of live remote execution.

SU-SEC-1 has R01–R08. SU-DECL-1 has Q01–Q13; expected passing answers are Yes except Q12 No. Any required not-checked result prevents passing. Code/source evidence and observed evidence remain distinct. Source and effect roles may differ and must be disclosed. Record environment limitations in the table; do not publish host paths, private repositories, tokens or earlier conversation.

The only source-inventory exclusions are these four outputs:

- `docs/security/security-report.json`
- `docs/security/declared-behavior-report.json`
- `docs/security/security-badge.svg`
- `docs/security/declared-behavior-badge.svg`

All other tracked source files, including static report HTML/CSS/JS, fixtures, instructions and generators, must be covered at the full recorded commit. New outputs can be committed after reviewed source to avoid circular hashes. `sh scripts/generate-audit-badges.sh --check` checks source consistency and the declared result, not whether the assessment really occurred or its conclusions are correct.
