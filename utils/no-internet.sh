#!/bin/bash

# disable all non-localhost network for processes in the
# no-internet group

::() {
    echo ":: $*" >&2
    "$@"
}

for tables in iptables ip6tables ; do
    :: $tables -A OUTPUT -m owner --gid-owner no-internet -d localhost -j ACCEPT
    :: $tables -A OUTPUT -m owner --gid-owner no-internet -j DROP
done

# In order to make it work: add a visudo-line like
# %users     ALL=(:no-internet)      NOPASSWD: ALL

# to make sound working under sudo, add

# Defaults env_keep += "XDG_RUNTIME_DIR"


