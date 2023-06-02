#!/usr/bin/env bash


object='clients.focus'
object=${object%.} # remove trailing '.'
mesg="Set an attribute of $object. "
mesg+="Anything after the first space will be used as the value"

rofi_args=(
        -monitor -2 # place above window
        -location 2 # aligned at top bottom
        -width 100  # use full window width
        -i  # case insensitive
        -l 10
        -dmenu
        -p "$object"
        -mesg "$mesg"
    )

::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}

mapfile -t attributes < <(herbstclient complete_shell 1 set_attr "$object".|grep ' $' )

full_hc_cmd=(
    chain
    )

for a in "${attributes[@]}" ; do
    a=${a% }
    name=${a##*.}
    herbstclient complete 2 set_attr "$a" \
        | sed "s.^.$name .g"
done | rofi "${rofi_args[@]}" | \
    {
    read -r command
    if [[ -z "$command" ]] ; then
        echo "no command given" >&2
        exit 1
    fi
    attr=${command%% *}
    value=${command#* }
    :: herbstclient set_attr "$object.$attr" "$value"
}



