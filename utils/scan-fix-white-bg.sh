#!/usr/bin/env bash

::() {
    echo ":: $*" >&2
    "$@"
}

:: mogrify -white-threshold '80%' "$@"
