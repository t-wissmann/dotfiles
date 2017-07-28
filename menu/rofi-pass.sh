#!/usr/bin/env bash

#set -e
# from passmenu
prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

clipwiz_key=Control-t
gen_key=Control-t
pkey() {
    printf "%-15s" "$*"
}

call_pass() {
    EDITOR="emacsclient -c --alternate-editor= " pass "$@"
}


terminal_pass() {
    rect=( $(herbstclient monitor_rect) )
    x=${rect[0]}+${rect[1]}
    y=${rect[1]}
    urxvt -override-redirect -geometry 60x8+$((x+10))+$((y+10)) -e pass "$@"
}

mesg="\
$(pkey Return       )| Open in an editor
$(pkey $clipwiz_key )| Copy credentials to clipboard
$(pkey $gen_key     )| Generate a new entry"

rofi_args=(
    -p 'pass> '
    -format i
    -kb-custom-1 "$clipwiz_key"
    -kb-custom-2 "$gen_key"
    -mesg "$mesg"

)

idx=$(printf '%s\n' "${password_files[@]}" \
    | sed 's,/, → ,g' \
    | rofi "${rofi_args[@]}" -dmenu )
exit_code=$?
case "$exit_code" in
    0)
        entry="${password_files[$idx]}"
        call_pass edit "$entry"
        ;;
    10) # kb-custom-1
        entry="${password_files[$idx]}"
        terminal_pass clipwiz "$entry"
        ;;
    11) # kb-custom-2
        entry="${password_files[$idx]}"
        call_pass gen "$entry"
        ;;
    *)
        ;;
esac



