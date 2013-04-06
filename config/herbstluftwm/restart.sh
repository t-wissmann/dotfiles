#!/bin/bash


STATEFILE=~/.config/herbstluftwm/state

~/dev/c/herbstluftwm/scripts/savestate.sh > "$STATEFILE" ||
~/git/herbstluftwm/scripts/savestate.sh > "$STATEFILE"
herbstclient wmexec "$@"

