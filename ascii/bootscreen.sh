#!/bin/bash


# the one from cowsay -f tux
TUX1=(
 '\e[0;37m           '
 '\e[0;37m    .--.   '
 '\e[0;37m   |\e[1;34mo\e[1;33m_\e[1;34mo \e[0;37m|  '
 '\e[0;37m   |\e[1;33m:_/ \e[0;37m|  '
 '\e[0;37m  /\e[1;37m/   \ \e[0;37m\ '
 '\e[0;37m |\e[1;37m|     | \e[0;37m|'
 '\e[1;33m/`\_   _/`\'
 '\e[1;33m\___)\e[0;37m=\e[1;33m(___/'
)


# original:
#    .-.
#   /o_o\
#   \\_//
#   /   \
#  (|   |)
#  /V\_/V\
#  \_/ \_/
TUX=(
'\e[0;37m  .-.  '
'\e[0;37m /\e[1;37mo\e[1;33m_\e[1;37mo\e[0;37m\ '
'\e[0;37m \\\e[1;33m\\_// '
'\e[0;37m /   \ '
'\e[1;33m(\e[0;37m|   |\e[1;33m)'
'\e[1;33m/V\\\e[0;37m_\e[1;33m/V\'
'\e[1;33m\_/ \_/'
)

englishflag=(
"\e[1;31;44m-.._\e[1;31;47m||\e[1;31;44m_..-\e[0m"
"\e[1;31;47m====++====\e[0m"
"\e[1;31;44m.--'\e[1;31;47m||\e[1;31;44m'--.\e[0m"
)

usaflag=(
'\e[1;37;44m*.*.*\e[1;31;47m▀▀▀▀▀\e[0m'
'\e[1;37;44m.*.*.\e[1;31;47m▀▀▀▀▀\e[0m'
'\e[1;31;47m▀▀▀▀▀\e[1;31;47m▀▀▀▀▀\e[0m'
)

germanflag=(
 '\e[0m__________'
'\e[40m          \e[0m'
'\e[41m          \e[0m'
'\e[43m          \e[0m'
)

germanmsg=(
    ''
    'Sie haben mein Notebook gefunden, vielen Dank!'
    'Bitte melden Sie sich bei mir telefonisch oder per E-Mail!'
    'Natürlich werden sie einen entsprechenden Finderlohn erhalten!'
)

englishmsg=(
    "You've found my laptop, thank you very much!"
    "Please contact me via phone or e-mail!"
    "Of course you will get an appropriate reward!"
)

vcardrow() {
    # $1 = name
    # $2 = value
    # $3 = extra padding for value
    printf "\e[1;31m|\e[1;33m %-15s\e[1;32m:\e[1;37m %-30s%s\e[1;31m|" \
        "$1" "$2" "$3"
}

vcardline="\e[1;31m+------------------------------------------------+"
logomsg=(
    "$vcardline"
    "$(vcardrow 'Name'          'Thorsten Wißmann ' ' ')"
    "$(vcardrow 'Address'       '....')"
    "$(vcardrow ''              '...')"
    "$(vcardrow 'Mobile-Phone'  '...')"
    "$(vcardrow 'Phone'         '...')"
    "$(vcardrow 'E-Mail'        '...')"
    "$(vcardrow ''              '...')"
    "$vcardline"
)

space='  '
logo=( "${TUX1[@]}")

echo
for i in "${!logomsg[@]}" ; do
    l="${logo[$i]}"
    [ -z "$l" ] && l='           '
    echo -ne " $l"
    echo -e "${space}${logomsg[$i]}"
done

echo
for i in "${!englishflag[@]}" ; do
    echo -ne "${space}${englishflag[$i]}"
    echo -e "${space}${englishmsg[$i]}"
done

for i in "${!germanflag[@]}" ; do
    echo -ne "${space}${germanflag[$i]}"
    echo -e "${space}${germanmsg[$i]}"
done
echo








