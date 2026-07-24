#!/usr/bin/env bash

INITEL=$HOME/.emacs.d/init.el

cmd="$1"
shift
case "$cmd" in
    update|install)
        exec emacs --batch -l "$INITEL" -f my/${cmd}-packages
        ;;
    *)
        echo "Unknown command \"$cmd\"" >&2
        exit 1
        ;;
esac

