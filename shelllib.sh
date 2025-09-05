#!/usr/bin/env bash


# some standard functions used in bash scripts
::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}

ask() {
    echo -n "==> $1 [y/n] "
    read -n 1 reply
    echo
    if [[ "${reply^^}" == 'Y' ]] ; then
        return 0
    else
        return 1
    fi
}

fail() {
    echo "$*" >&2 ; exit 1
}
