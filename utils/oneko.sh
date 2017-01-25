#!/usr/bin/env bash

# reset this via:
#
#   killall oneko
#   xsetroot -cursor_name left_ptr


# spawn a random oneko

themes=(
    -neko
    -tora
)
# colors to use: fillcolor,bordercolor
colors=(
    '#DCDCDC,#383838'
    '#A88A53,#60430E'
    '#FFA500,#6C4600'
    '#AFAFAF,#2F2F2F'
    '#FFC0CB,#770015'
)

count=10

for i in $(seq 1 $count) ; do

t=${themes[$((i % ${#themes[@]}))]}
c=${colors[$((i % ${#colors[@]}))]}
x=$((RANDOM % 60 + 10* $i))
y=$((RANDOM % 60 + 10* $i))
speed=$((10 + RANDOM % 15))

echo oneko -fg "${c##*,}" -bg "${c%%,*}" "$t" -speed "$speed" -position "0x0+${x}+${y}"
oneko -fg "${c##*,}" -bg "${c%%,*}"  "$t" -speed "$speed" -position "0x0+${x}+${y}" &

done
