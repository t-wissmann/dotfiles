#!/usr/bin/env bash


if [[ $(< /sys/class/drm/card0/*HDMI*/status) = connected ]] ; then
    echo "Audio output: HDMI"
    pactl set-card-profile 0 output:hdmi-stereo+input:analog-stereo
else
    echo "Audio output: analog"
    pactl set-card-profile 0 output:analog-stereo+input:analog-stereo
fi



