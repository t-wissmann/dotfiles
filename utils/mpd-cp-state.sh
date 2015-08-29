#!/bin/bash -e

cmd_name=$0
print_help() {
cat <<EOF
Usage: $0 FROM TO

Copies the state (current playlist, played track, playing offset) from host
specified in FROM to that in TO.

Each of FROM and TO are formatted in one of the following ways:

  HOST:PORT     denotes HOST and port PORT
  HOST          denotes HOST and the port \$MPD_PORT
  .             denotes \$MPD_HOST and \$MPD_PORT

If empty, \$MPD_HOST defaults to localhost and \$MPD_PORT to 6600.

EOF
}

fill_default_values() {
    if [ "$1" = "." ] ; then
        # host specification "." denotes "mpd host here"
        echo "${MPD_HOST:-localhost}:${MPD_PORT:-6600}"
    elif [ "${1%:*}" = "${1}" ] ; then
        # if no port is specified, add one
        echo "${1}:${MPD_PORT:-6600}"
    fi
}

from=${1}
to=${2}
if [ -z "$from" ] || [ -z "$to" ] ; then
    print_help >&2
    exit 1
fi
from=$(fill_default_values "$from")
to=$(fill_default_values "$to")

from_host=${from%:*}
from_port=${from##*:}
to_host=${to%:*}
to_port=${to##*:}

do_at_from() {
    MPD_HOST="$from_host" MPD_PORT="$from_port" "$@"
}
do_at_to() {
    MPD_HOST="$to_host" MPD_PORT="$to_port" "$@"
}
::() {
    echo ":: $*" >&2
}

:: "Transferring the state from $from_host (port $from_port) to $to_host (port $to_port)"
:: "Clearing target playlist"
do_at_to mpc stop
do_at_to mpc clear
:: "Copying playlist"
do_at_from mpc playlist --format "%file%" | do_at_to mpc add
:: "Playing at same position"
do_at_to mpc play $(do_at_from mpc current --format '%position%')
do_at_to mpc seek $(do_at_from mpc -f '' status \
                    | awk '{ print $3 }' | sed -n '2s,/.*,,p')


