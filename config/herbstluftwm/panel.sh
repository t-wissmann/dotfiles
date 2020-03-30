#!/usr/bin/env bash


if [ $HOSTNAME = hoth ] ; then
    exit 0
else
    exec ~/git/barpyrus/barpyrus.py "$@"
fi
