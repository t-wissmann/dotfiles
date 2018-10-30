#!/bin/bash

# setup scripts dir

::() {
    echo ":: $*" >&2
    "$@"
}
:: mkdir -p ~/.config/mpv/scripts/
:: ln -sf /usr/lib/mpv/mpris.so ~/.config/mpv/scripts/
