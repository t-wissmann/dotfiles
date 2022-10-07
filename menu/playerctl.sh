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

Also, if exactly one player is playing currently, then all actions are sent to
that unique player.

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

set_player_selection() {
    echo "Switching to player: $1" >&2
    PLAYERCTL_SELECTION="$1"
    herbstclient export PLAYERCTL_SELECTION="$1"
}

PLAYERCTL_SELECTION=${PLAYERCTL_SELECTION:-$(herbstclient getenv PLAYERCTL_SELECTION)}
mapfile -t playing < <(playerctl -a -f '{{status}}:{{playerInstance}}' status|grep '^Playing:'|sed 's,[^:]*:,,')

unique_player() {
    [[ "${#playing[@]}" -eq 1 ]]
}

if [[ "$1" = menu ]] || { ! unique_player && ! selected_player_exists ; } ; then
    # enter selection if 'menu' was requested, or if it is not clear which
    # player is meant.
    p=$(playerctl -l | rofi -dmenu -p "Select a default player")
    if [[ $? -eq 0 ]] ; then
        set_player_selection "$p"
    else
        exit 1
    fi
else
    # echo "playing count: ${#playing[@]} (${playing[@]})"

    if [[ "${#playing[@]}" -eq 1 ]] && [[ "${playing[0]}" != "$PLAYERCTL_SELECTION" ]] ; then
        # if exactly one player is playing, then automatically switch to that one
        set_player_selection "${playing[0]}"
    fi
fi

if [[ "$1" != menu ]] ; then
    playerctl --player "$PLAYERCTL_SELECTION" "$@"
fi

# vim: tw=80
