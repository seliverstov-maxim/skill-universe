#!/usr/bin/env python3
"""Generate per-methodology audit badges; --check detects stale reports/output."""
import hashlib
from pathlib import Path
import re
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
methods = [
    ('SU-SEC-1', 'docs/security/security-report.md', 'docs/security/security-badge.svg'),
    ('SU-DECL-1', 'docs/security/declared-behavior-report.md', 'docs/security/declared-behavior-badge.svg'),
]
outputs = {path for _, report, badge in methods for path in (report, badge)}
tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=root).decode().split('\0')
paths = sorted(set(tracked) - outputs - {''})
if sys.argv[1:] not in ([], ['--check']):
    sys.exit('Usage: python3 scripts/generate-audit-badge.py [--check]')

badges = {}
for method, report_path, badge_path in methods:
    report = (root / report_path).read_text()
    revision = re.search(r'^- Reviewed by Codex at \[`([0-9a-f]{40})`\]', report, re.M)
    result = re.search(r'^- Result: \*\*(passing|failing|incomplete)\*\*$', report, re.M)
    if not revision or not result:
        sys.exit(f'{method}: report must identify the full reviewed commit and result.')
    revision, result = revision[1], result[1]
    expected = dict(re.findall(r'^\| `([^`]+)` \| `([0-9a-f]{64})` \|$', report, re.M))
    if set(paths) != set(expected):
        sys.exit(f'{method}: audit coverage is stale; review all tracked files.')
    for path in paths:
        committed = subprocess.check_output(['git', 'show', f'{revision}:{path}'], cwd=root)
        if any(hashlib.sha256(data).hexdigest() != expected[path]
               for data in (committed, (root / path).read_bytes())):
            sys.exit(f'{method}: audit is stale; {path} differs from the reviewed source.')
    color = {'passing': '#4c1', 'failing': '#e05d44', 'incomplete': '#9f9f9f'}[result]
    badges[badge_path] = f'''<svg xmlns="http://www.w3.org/2000/svg" width="175" height="20" role="img" aria-label="{method}: {result}">
  <title>{method}: {result}. Reviewed by Codex at {revision}. See linked report for scope and findings.</title>
  <rect width="175" height="20" rx="3" fill="#555"/>
  <path fill="{color}" d="M91 0h81a3 3 0 0 1 3 3v14a3 3 0 0 1-3 3H91z"/>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,sans-serif" font-size="11">
    <text x="45.5" y="14">{method}</text>
    <text x="133" y="14">{result}</text>
  </g>
</svg>
'''

for path, svg in badges.items():
    if sys.argv[1:] == ['--check']:
        if not (root / path).exists() or (root / path).read_text() != svg:
            sys.exit('Badge is stale: run python3 scripts/generate-audit-badge.py.')
    else:
        (root / path).write_text(svg)
