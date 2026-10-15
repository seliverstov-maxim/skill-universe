#!/bin/sh
# Shared validation and rollback for commands that change user state.
set -eu
umask 077
. "$(dirname "$0")/paths.sh"

fail() { printf '%s\n' "$*" >&2; exit 1; }
name_ok() {
    case "$1" in ''|.|..|*[!a-zA-Z0-9._-]*) fail "Invalid name: $1 (use letters, digits, dot, underscore or dash)" ;; esac
}
source_ok() {
    [ ! -L "$1" ] || fail "Source symlink is not allowed: $1"
    find "$1" -type l -print > "$work/links"
    [ ! -s "$work/links" ] || fail "Source contains symlinks: $1"
}
# Check the complete candidate tree before making an update visible via symlinks.
tree_ok() {
    git -C "$1" ls-tree -r "$2" -- skills rules > "$work/tree"
    if grep -q '^120000 ' "$work/tree"; then
        fail 'Source symlinks under skills/ or rules/ are not allowed'
    fi
}
empty_destination() {
    if [ -e "$1" ] || [ -L "$1" ]; then
        fail "Destination already exists: $1"
    fi
}
remember() {
    case "$1" in *'
'*) fail 'Newlines in destination paths are not supported' ;; esac
    for record in "$work"/entry.*; do
        [ -d "$record" ] || continue
        [ "$(cat "$record/path")" != "$1" ] || return 0
    done
    record=$(mktemp -d "$work/entry.XXXXXX")
    printf '%s\n' "$1" > "$record/path"
    if [ -L "$1" ]; then
        cp -P "$1" "$record/original"
    elif [ -f "$1" ]; then
        cp -p "$1" "$record/original"
    else
        [ ! -e "$1" ] || fail "Expected a file or symlink: $1"
    fi
    touch "$record/ready"
}
finish() {
    result=$?
    trap - 0 HUP INT TERM
    if [ "$result" -ne 0 ]; then
        if [ -f "$work/git-pending" ]; then
            printf 'Git update interrupted; recovery needed. Details and backups: %s; lock: %s\n' "$work" "$state/lock" >&2
            exit "$result"
        fi
        restored=yes
        for record in "$work"/entry.*; do
            [ -f "$record/ready" ] || continue
            destination=$(cat "$record/path")
            if [ -e "$record/original" ] || [ -L "$record/original" ]; then
                rm -f -- "$destination" && cp -Pp "$record/original" "$destination" || restored=no
            else
                rm -f -- "$destination" || restored=no
            fi
        done
        if [ "$restored" = no ]; then
            printf 'Recovery needed. Backups retained in %s; lock: %s\n' "$work" "$state/lock" >&2
            exit "$result"
        fi
    fi
    rm -rf -- "$work"
    rmdir "$state/lock"
    exit "$result"
}
checkpoint_manifest() {
    for record in "$work"/entry.*; do
        [ -f "$record/ready" ] || continue
        if [ "$(cat "$record/path")" = "$manifest" ]; then
            cp -p "$manifest" "$record/checkpoint"
            mv -f "$record/checkpoint" "$record/original"
        fi
    done
}
# shellcheck disable=SC2034 # directory_key and suffix are outputs consumed by sourcing commands.
select_entry() {
    name_ok "$1"
    kind=$(jq -er --arg alias "$1" 'if (.skills | has($alias)) then "skills"
        elif ((.rules // {}) | has($alias)) then "rules" else error("Alias not installed") end' "$manifest")
    directory_key=directory; suffix=''
    if [ "$kind" = rules ]; then directory_key=rules_directory; suffix=.md; fi
}
directories() {
    jq -er --arg key "$directory_key" '.harnesses[][$key] |
        if type == "string" and length > 0 and (contains("\n") | not) then . else error("Invalid harness directory") end' \
        "$manifest" > "$work/directories"
}
expand_directory() {
    # shellcheck disable=SC2088 # Match literal ~/ before expanding it explicitly with HOME.
    case "$directory" in '~/'*) directory="$HOME/${directory#\~/}" ;; esac
    case "$directory" in /*) ;; *) fail "Harness directory must be absolute: $directory" ;; esac
}
# shellcheck disable=SC2154 # alias is set by remove/rename before calling this sourced function.
managed_link() {
    [ -L "$1" ] || fail "Installed link is missing or replaced: $1"
    url=$(jq -er --arg kind "$kind" --arg alias "$alias" '.[$kind][$alias].url' "$manifest")
    branch=$(jq -er --arg kind "$kind" --arg alias "$alias" '.[$kind][$alias].branch' "$manifest")
    path=$(jq -er --arg kind "$kind" --arg alias "$alias" '.[$kind][$alias].path' "$manifest")
    checkout_id=$(printf '%s\n%s\n' "$url" "$branch" | git hash-object --stdin)
    [ "$(readlink "$1")" = "$state/repos/$checkout_id/$path" ] || fail "Installed link target was changed: $1"
}

mkdir -p "$state"
mkdir "$state/lock" 2>/dev/null || fail "Another command is running, or recovery is needed: $state/lock"
# Install the trap before creating temporary state.
work=''
trap 'rmdir "$state/lock"' 0
work=$(mktemp -d "$state/transaction.XXXXXX")
trap finish 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
manifest="$state/manifest.json"
[ ! -L "$manifest" ] || fail 'The manifest must not be a symlink'
remember "$manifest"
