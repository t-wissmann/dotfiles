#!/usr/bin/env bash

del_key=Alt-Return
add_key=Alt-Delete
mesg="\
Enter      : select a tag to focused
$del_key : delete selected tag
$add_key : create new tag with name as entered"
rofi_args=(
    -dmenu
    -p "tag:"
    -kb-custom-1 "$del_key"
    -kb-custom-2  "$add_key"
    -mesg "$mesg"
)

res=$(herbstclient complete 1 use | rofi "${rofi_args[@]}")
exit_code=$?
case "$exit_code" in
    10)
        herbstclient chain , add "$res" , use "$res"
        ;;
    11)
        herbstclient merge_tag "$res"
        ;;
    0)
        herbstclient use "$res"
        ;;
    *)
        ;;
esac


