#!/bin/bash

f=~/git/herbstluftwm/scripts/wselect.sh
[ -x "$f" ] ||
f=/usr/share/doc/herbstluftwm/examples/wselect.sh
[ -x "$f" ] ||
echo "can't find wselect.sh"

exec "$f" "$@"

