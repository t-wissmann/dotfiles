#!/bin/bash

set -e
set -u
set -o pipefail


usage() {
cat <<EOF
usage: $prog DIRECTORY

Plots the size development of the given DIRECTORY.
EOF
}
prog="$0"

dir="$1"
if [[ "$1" = '-h' ]] || [[ "$1" = '--help' ]] ; then
    usage
    exit 0
fi
if [[ -z "$1" ]] ; then
    usage >&2
    exit 1
fi

gnuplot_config() {
    file="$1"
cat <<EOF
set datafile separator " "
set xdata time
set timefmt '%Y/%m'
set format x '%b %Y'
set xtics mirror
set format y "%.0fKB"
#set xtics rotate by -30
set boxwidth 1444884.5
set style fill solid

set ylabel "Additional size per month"
set y2label "Total size up to month"
set y2tics
set format y2 "%.0fMB"
set grid x y2 y
set ytics nomirror
set y2tics nomirror

a=0
#gnuplot 4.4+ functions are now defined as:  
#func(variable1,variable2...)=(statement1,statement2,...,return value)
cumulative_sum(x)=(a=a+x,a)

set yrange [0:700]

plot "$file" using 1:2 axes x1y1 title "Per Month" smooth unique with boxes , \
     "$file" using 1:(cumulative_sum(\$2)/1000) axes x1y2 title "In Total" smooth unique with lines
EOF
}

plot_data() {
    file="$1"
    gnuplot_config "$file" | gnuplot --persist
}
tmpfile=$(mktemp)
find "$dir" -type f -printf '%TY/%Tm %k\n' | sort > "$tmpfile"
plot_data "$tmpfile"
rm "$tmpfile"

