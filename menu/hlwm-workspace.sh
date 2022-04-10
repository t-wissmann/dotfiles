#!/usr/bin/env bash

del_key=Alt-BackSpace
add_key=Alt-Return
rename_key=Alt-r
shift_key=Alt-m
pkey() {
    printf "%-14s" "$*"
}


default_action_str='go to the tag'
default_action() {
    herbstclient use "$1"
}

move_action_str='go to the tag and bring the window with'
move_action() {
    herbstclient chain , add "$1" , use "$1" , bring "$focus_window_id"
}

case "$1" in
    --move)
        default_action_str="$move_action_str"
        default_action() {
            move_action "$@"
        }
        ;;
    *)
        ;;
esac

mesg="\
$(pkey Return     )| $default_action_str
$(pkey $shift_key )| $move_action_str
$(pkey $del_key   )| delete selected tag
$(pkey $add_key   )| create new tag with name as entered
$(pkey $rename_key)| rename the current tag"

rofi_args=(
    -dmenu
    -p "tag:"
    -i
    -select "$(herbstclient get_attr tags.focus.name)"
    -kb-custom-1 "$add_key"
    -kb-custom-2 "$del_key"
    -kb-custom-3 "$shift_key"
    -kb-custom-4 "$rename_key"
    -mesg "$mesg"
)
#echo rofi "${rofi_args[@]}"
focus_window_id="$(herbstclient get_attr clients.focus.winid)"
res=$(herbstclient complete 1 use | rofi "${rofi_args[@]}")
exit_code=$?
case "$exit_code" in
    10)
        herbstclient chain , add "$res" , use "$res"
        ;;
    11)
        # if the tag to be deleted is focused, then switch to the previously
        # used tag
        herbstclient chain \
            , and / compare tags.focus.name = "$res" \
                  / use_previous \
            , merge_tag "$res"
        ;;
    12)
        move_action_str "$res"
        ;;
    13)
        herbstclient chain \
            , merge_tag "$res" \
            , attr tags.focus.name "$res"
        ;;
    0)
        default_action "$res"
        ;;
    *)
        ;;
esac


