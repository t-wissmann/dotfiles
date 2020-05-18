#!/usr/bin/env bash

::() {
    echo ":: $*" >&2
    "$@"
}

THRESHOLD=${THRESHOLD:-80}

:: mogrify -white-threshold "$THRESHOLD%" "$@"
