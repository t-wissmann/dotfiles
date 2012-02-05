#!/bin/bash
t=$(tput setaf 3) # tree color
n=$(tput setaf 2) # name
v=$(tput setaf 7) # value
f="" #just for alignment :D

distro="ArchLinux"
if [ -f /etc/debian_version ] ; then
    distro="Debian $(cat /etc/debian_version)"
fi

status=
if ps cu|grep conky > /dev/null ; then
    status=$(conky --version|head -1|cut -d' ' -f1,2)
else
    status=none
fi

terminal=urxvt
font='bitstream vera sans'
browser=luakit

b="$(tput sgr0)$(tput setaf 5)"
logo1="$(tput setaf 3) (()   "
logo2="$b /$(tput bold)$(tput setaf 4)°$b\__$(tput bold)$(tput setaf 7)."
logo3="$b  \___/"
logo4="$(tput bold)$(tput setaf 3)  /\ /\\"
space="       "

logo1+="$(tput sgr0)"
logo2+="$(tput sgr0)"
logo3+="$(tput sgr0)"
logo4+="$(tput sgr0)"

cat <<EOF
 ${v} x $t╾───╮
$space$t ├─${n}WM:$v Herbstluftwm$t─┬─${n}version: $v$(herbstluftwm --version|head -1)
$logo1$t │                  ├─${n}panel:$v dzen2
$logo2$t ├─${n}OS:$v $(printf %-13s "$distro")${t}╰─${n}statusbar: $v$status
$logo3$t ├─${n}Kernel: $v$(uname -sr)
$logo4 $t├─${n}Shell:$v $SHELL
$space$t ├─${n}Terminal:$v $terminal$t──${n}Font: $v$font
$space$t ╰─${n}Browser:$v $browser
EOF


# reset colors
tput sgr0

