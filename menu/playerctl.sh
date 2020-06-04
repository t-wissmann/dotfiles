#!/usr/bin/env bash

prog=$0
usage(){
cat <<EOF
$prog [menu|PLAYERCTL_COMMAND ...]

This is a wrapper around playerctl that remembers a default
player to use in the environment variable \$PLAYERCTL_SELECTION
and applies the provided player command only to that player.

Additionally, the subcommand 'menu' shows a rofi menu that allows
updating the default player (\$PLAYERCTL_SELECTION). This requires
both rofi and herbstluftwm (the environment option in the window
manager process is updated).

If the selected player is not active anymore, the selection menu is shown
before the given playerctl-command is executed (in particular on the first
run).

Example usage:

    $prog play-pause
        Play-pauses the default player, and shows the selection menu
        on the first run.

    $prog menu
        Shows the player selection menu (via rofi).

EOF
}

if [[ "$1" = -h ]] || [[ "$1" = --help ]] ; then
    usage
    exit 0
fi

selected_player_exists() {
    playerctl -l | grep -x "$PLAYERCTL_SELECTION" > /dev/null
}

PLAYERCTL_SELECTION=${PLAYERCTL_SELECTION:-$(herbstclient getenv PLAYERCTL_SELECTION)}

if [[ "$1" = menu ]] || ! selected_player_exists ; then
    p=$(playerctl -l | rofi -dmenu -p "Select a default player")
    if [[ $? -eq 0 ]] ; then
        PLAYERCTL_SELECTION="$p"
        herbstclient export PLAYERCTL_SELECTION="$p"
    else
        exit 1
    fi
fi

if [[ "$1" != menu ]] ; then
    playerctl --player "$PLAYERCTL_SELECTION" "$@"
fi

# vim: tw=80
