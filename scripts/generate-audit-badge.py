#!/usr/bin/env python3
"""Generate the audit badge from a committed report; --check detects stale output."""
import hashlib
from pathlib import Path
import re
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
report_path = 'docs/security/report.md'
badge_path = 'docs/security/audit.svg'
report = (root / report_path).read_text()
match = re.search(r'^- Reviewed by Codex at \[`([0-9a-f]{40})`\]', report, re.M)
if not match:
    sys.exit('Report must identify the full reviewed commit.')
revision = match[1]
expected = dict((path, digest) for path, digest in re.findall(
    r'^\| `([^`]+)` \| `([0-9a-f]{64})` \|$', report, re.M))
tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=root).decode().split('\0')
paths = sorted(set(tracked) - {'', report_path, badge_path})
if set(paths) != set(expected):
    sys.exit('Audit coverage is stale: review all tracked files and update the report.')
for path in paths:
    committed = subprocess.check_output(['git', 'show', f'{revision}:{path}'], cwd=root)
    if any(hashlib.sha256(data).hexdigest() != expected[path]
           for data in (committed, (root / path).read_bytes())):
        sys.exit(f'Audit is stale: {path} differs from the reviewed source.')

label = f'Codex {revision[:7]}'
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="234" height="20" role="img" aria-label="Internal audit: {label}">
  <title>Internal source audit by Codex at {revision}. See linked report for scope and findings.</title>
  <rect width="234" height="20" rx="3" fill="#555"/>
  <path fill="#007ec6" d="M87 0h144a3 3 0 0 1 3 3v14a3 3 0 0 1-3 3H87z"/>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,sans-serif" font-size="11">
    <text x="43.5" y="14">Internal audit</text>
    <text x="160.5" y="14">{label}</text>
  </g>
</svg>
'''
if sys.argv[1:] == ['--check']:
    if not (root / badge_path).exists() or (root / badge_path).read_text() != svg:
        sys.exit('Badge is stale: run python3 scripts/generate-audit-badge.py.')
elif not sys.argv[1:]:
    (root / badge_path).write_text(svg)
else:
    sys.exit('Usage: python3 scripts/generate-audit-badge.py [--check]')
