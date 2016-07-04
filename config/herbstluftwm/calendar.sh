#!/bin/bash
#
# pop-up calendar for dzen
#
# (c) 2007, by Robert Manea
#

width=180
padding=10
monitor=( $(herbstclient list_monitors |
    grep '\[FOCUS\]$'|cut -d' ' -f2|
    tr x ' '|sed 's/\([-+]\)/ \1/g') )
x=$((${monitor[2]} + ${monitor[0]} - width - padding))


 
TODAY=$(expr `date +'%d'` + 0)
MONTH=`date +'%m'`
YEAR=`date +'%Y'`
 
(
echo '^bg(grey70)^fg(#111111)'
#date +'%A, %d.%m.%Y %H:%M'
 
# current month, highlight header and today
cal | sed -e "1 s/^\s*//; 3,$ s/\(.*\)/\1                    /; 3,$ s/\(.\{20\}\).*/\1/" \
	| sed -r -e "1,2 s/.*/^fg(white)&^fg()/" \
		 -e "s/(^| )($TODAY)($| )/\1^bg(white)^fg(#111)\2^fg()^bg()\3/"
 
echo "---------------------"
# next month, hilight header
[ $MONTH -eq 12 ] && YEAR=`expr $YEAR + 1`
cal `expr \( $MONTH + 1 \) % 12` $YEAR \
    | sed -e "1 s/^\s*//; 1,2 s/.*/^fg(white)&^fg()/; 3,$ s/\(.*\)/\1                    /; 3,$ s/\(.\{20\}\).*/\1/"
) \
    |  dzen2 -p 60 -fn 'Monospace-9' -x $x -y 20 -w $width -l 17 -sa c -e 'onstart=uncollapse;button1=exit;button3=exit' -bg '#242424' 
