#!/usr/bin/env bash


# some standard functions used in bash scripts
::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}

ask() {
    echo "==> $1 [y/n]"
    read -n 1 reply
    if [[ "${reply^^}" == 'Y' ]] ; then
        return 0
    else
        return 1
    fi
}
