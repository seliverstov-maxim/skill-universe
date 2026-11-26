#!/bin/sh
. "$(dirname "$0")/../env.sh"
state=$SKILL_UNIVERSE_HOME
case "$state" in
    /*) ;;
    *) printf 'Expected an absolute path: %s\n' "$state" >&2; exit 1 ;;
esac
