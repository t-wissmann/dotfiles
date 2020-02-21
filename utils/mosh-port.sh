#!/usr/bin/env bash

##   connect to a given host via this port
##   if this fails, ssh there and kill the orphaned mosh server
port=$1
host=$2

::() {
    echo ":: $*" >&2
    "$@"
}
log() {
    echo ">> $*" >&2
}

log "Check whether port $port is free"
:: mosh -p "$port" "$host" true

if [ "$?" -eq 10 ] ; then
    log "Port $port seems to be used already"
    # since we use [-]p, the following command does not return itself as a result
    log "ssh'ing to $uber ... "
    ssh -t "$host" "
        pid=\$( ps aux | sed 's,[ ]* , ,g' \
                       | grep mosh-server  \
                       | grep '[-]p $port' \
                       | tee /dev/stderr   \
                       | cut -d' ' -f 2)
        if [ -n \"\$pid\" ] ; then
            read -n 1 -p \"Kill the command with pid \$pid? [yn]\" res
            echo
            if [ \"\$res\" = y ] ; then
                echo kill \"\$pid\"
                kill \"\$pid\"
            else
                exit 1
            fi
        else
            echo No mosh-server for port $port found
            exit 1
        fi
    "
    # check the exit code of ssh
    if [ "$?" -ne 0 ] ; then
        log "Nothing changed, exiting ..."
        exit 1
    fi
else
    log "Port $port is free"
fi

exec mosh -p "$port" "$host"

