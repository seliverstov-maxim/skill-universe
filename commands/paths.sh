#!/bin/sh
# User-controlled locations; defaults remain unchanged.
state=${SKILL_UNIVERSE_HOME:-"$HOME/.skill-universe"}
case "$state" in
    /*) ;;
    *) printf 'Expected an absolute path: %s\n' "$state" >&2; exit 1 ;;
esac
