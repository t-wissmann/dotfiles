#!/usr/bin/env bash


# some standard functions used in bash scripts
::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}
