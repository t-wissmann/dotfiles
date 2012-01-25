#!/bin/bash
source ~/.bash_settings
id=$(wmctrl -l | $dmenu_command -l $dmenu_lines ) && xdotool windowactivate ${id%% *}
