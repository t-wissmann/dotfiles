#!/usr/bin/env bash


if [ $HOSTNAME = hoth ] ; then
    geo=$(herbstclient attr monitors."$1".geometry)
    x_coord=${geo#*+}
    y_coord=${x_coord#*+}
    x_coord=${x_coord%+*}
    if [ "$x_coord" -lt "1920" ] ; then
        # no panel on hoth on left monitor
        exit 0
    else
        exec ~/git/barpyrus/barpyrus.py "$@"
    fi
else
    exec ~/git/barpyrus/barpyrus.py "$@"
fi
