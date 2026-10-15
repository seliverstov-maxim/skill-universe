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
    case "$result" in
        passing) top_color='#34D058'; bottom_color='#28A745'; state_width=50 ;;
        failing) top_color='#F97583'; bottom_color='#D73A49'; state_width=44 ;;
        incomplete) top_color='#959DA5'; bottom_color='#6A737D'; state_width=70 ;;
    esac
    if [ "$method" = SU-SEC-1 ]; then label_width=78; else label_width=86; fi
    width=$((label_width + state_width))
    cat > "$work/$stem.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="20" role="img" aria-label="$method: $result">
  <title>$method: $result. Reviewed by Codex at $revision. See linked report for scope and findings.</title>
  <defs>
    <linearGradient id="label" x2="0" y2="100%"><stop stop-color="#444D56"/><stop offset="1" stop-color="#24292E"/></linearGradient>
    <linearGradient id="state" x2="0" y2="100%"><stop stop-color="$top_color"/><stop offset="1" stop-color="$bottom_color"/></linearGradient>
    <clipPath id="badge"><rect width="$width" height="20" rx="3"/></clipPath>
  </defs>
  <g clip-path="url(#badge)">
    <path fill="url(#label)" d="M0 0h$label_width v20H0z"/>
    <path fill="url(#state)" d="M$label_width 0h$state_width v20H$label_width z"/>
  </g>
  <path fill="#959DA5" d="M11 3 5 5v5c0 3.5 3.5 6 6 7 2.5-1 6-3.5 6-7V5z"/>
  <path fill="none" stroke="#303841" stroke-width="1.4" d="m8 10 2 2 4-4"/>
  <g font-family="'DejaVu Sans',Verdana,Geneva,sans-serif" font-size="11">
    <g fill="#010101" fill-opacity=".3" aria-hidden="true"><text x="22" y="15">$method</text><text x="$((label_width + 4))" y="15">$result</text></g>
    <g fill="#fff"><text x="22" y="14">$method</text><text x="$((label_width + 4))" y="14">$result</text></g>
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
