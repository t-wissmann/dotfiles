#!/usr/bin/env bash

del_key=Alt-Delete
add_key=Alt-Return
shift_key=Alt-m
pkey() {
    printf "%-12s" "$*"
}

mesg="\
$(pkey Return     )| go to the tag
$(pkey $shift_key )| go to the tag and bring the window with
$(pkey $del_key   )| delete selected tag
$(pkey $add_key   )| create new tag with name as entered"

rofi_args=(
    -dmenu
    -p "tag:"
    -select "$(herbstclient get_attr tags.focus.name)"
    -kb-custom-1 "$add_key"
    -kb-custom-2 "$del_key"
    -kb-custom-3 "$shift_key"
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
        #echo herbstclient chain , move "$res" , use "$res"
        herbstclient chain , use "$res" , bring "$focus_window_id"
        ;;
    0)
        herbstclient use "$res"
        ;;
    *)
        ;;
esac


