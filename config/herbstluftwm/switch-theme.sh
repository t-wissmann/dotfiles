#!/usr/bin/env bash


THEMEDIR=~/.config/herbstluftwm/themes
if newtheme=$(find "$THEMEDIR" -type f -name '*.css' -printf '%P\0' | fzf --read0)
then
    herbstclient attr theme.name "$THEMEDIR/$newtheme"
fi

