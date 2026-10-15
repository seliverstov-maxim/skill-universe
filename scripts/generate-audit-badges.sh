#!/bin/sh
# Validate source/report consistency and generate the two methodology badges.
set -eu
root=$(CDPATH='' cd "$(dirname "$0")/.." && pwd)
cd "$root"
case "${1-}" in ''|--check) ;; *) printf 'Usage: %s [--check]\n' "$0" >&2; exit 1 ;; esac
work=$(mktemp -d)
trap 'rm -rf -- "$work"' 0
hash() {
    if command -v sha256sum >/dev/null; then sha256sum "$1"; else shasum -a 256 "$1"; fi | awk '{print $1}'
}
git ls-files | LC_ALL=C sort | while IFS= read -r path; do
    case "$path" in
        docs/security/security-report.json|docs/security/declared-behavior-report.json|docs/security/security-badge.svg|docs/security/declared-behavior-badge.svg) ;;
        *) printf '%s\n' "$path" ;;
    esac
done > "$work/paths"
for method in SU-SEC-1 SU-DECL-1; do
    if [ "$method" = SU-SEC-1 ]; then stem=security; count=8; else stem=declared-behavior; count=13; fi
    report="docs/security/$stem-report.json"
    jq -e --arg method "$method" --argjson count "$count" '
        .method == $method and (.commit | test("^[0-9a-f]{40}$")) and
        (.result == "passing" or .result == "failing" or .result == "incomplete") and
        (.checks | length == $count) and
        (if .method == "SU-SEC-1" then [.checks[].id] == [range(1;9) | "R0" + tostring] else true end) and
        (if .result == "passing" then all(.checks[];
            .code == "passed" and (.observed == "passed" or .observed == "not-applicable")) else true end) and
        (if .method == "SU-DECL-1" and .result == "passing" then
            ([.checks[].id] == [range(1;14) | "Q" + (if . < 10 then "0" else "" end) + tostring]) and
            all(.checks[]; .answer == (if .id == "Q12" then "No" else "Yes" end)) else true end)
    ' "$report" >/dev/null || { printf 'Invalid audit result: %s\n' "$report" >&2; exit 1; }
    revision=$(jq -r '.commit' "$report")
    result=$(jq -r '.result' "$report")
    jq -r '.files | keys[]' "$report" | LC_ALL=C sort > "$work/expected"
    cmp "$work/paths" "$work/expected" || { printf 'Audit inventory is stale: %s\n' "$method" >&2; exit 1; }
    while IFS= read -r path; do
        expected=$(jq -r --arg path "$path" '.files[$path]' "$report")
        git show "$revision:$path" > "$work/source"
        if [ "$(hash "$work/source")" != "$expected" ] || [ "$(hash "$path")" != "$expected" ]; then
            printf 'Audit source is stale: %s (%s)\n' "$path" "$method" >&2; exit 1;
        fi
    done < "$work/paths"
    case "$result" in passing) color='#4c1' ;; failing) color='#e05d44' ;; incomplete) color='#9f9f9f' ;; esac
    cat > "$work/$stem.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="175" height="20" role="img" aria-label="$method: $result">
  <title>$method: $result. Reviewed by Codex at $revision. See linked report for scope and findings.</title>
  <rect width="175" height="20" rx="3" fill="#555"/>
  <path fill="$color" d="M91 0h81a3 3 0 0 1 3 3v14a3 3 0 0 1-3 3H91z"/>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,sans-serif" font-size="11">
    <text x="45.5" y="14">$method</text><text x="133" y="14">$result</text>
  </g>
</svg>
SVG
done
for stem in security declared-behavior; do
    destination="docs/security/$stem-badge.svg"
    if [ "${1-}" = --check ]; then
        cmp "$work/$stem.svg" "$destination" || { printf 'Regenerate audit badges.\n' >&2; exit 1; }
    else
        cp "$work/$stem.svg" "$destination"
    fi
done
