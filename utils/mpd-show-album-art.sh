#!/usr/bin/env bash

file=$(mpc current -f '%file%')

mpc -q albumart "$file" | feh --image-bg '#323232' --scale-down - \
    || mpc -q readpicture "$file" | feh --image-bg '#323232' --scale-down -
