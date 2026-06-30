#!/usr/bin/env bash
set -u

trap echo EXIT # Print newline on exit

now() { date +%s; }

draw() {
    local secs=$(( $(now) - start_ts ))
    printf '\r  %02d:%02d:%02d  %ds   ' \
        $(( secs / 3600 )) $(( (secs % 3600) / 60 )) $(( secs % 60 )) "$secs"
}

printf 'Stopwatch  -  r: reset   q: quit\n\n'
start_ts=$(now)

while true; do
    draw

    # Read one key (no Enter needed) with a short timeout so the display keeps
    # ticking. -s: no echo, IFS= keeps Space from being stripped.
    IFS= read -rsn1 -t 0.1 key

    case "$key" in
        r)           start_ts=$(now) ;;
        q)           break ;;
        '')          ;;   # timeout, no key - just redraw
    esac
done
