#!/usr/bin/env bash


configfile=$(dirname $0)/FAU-Fulltunnel.ovpn

echo :: sudo openvpn --config "$configfile"
exec sudo openvpn --config "$configfile"

