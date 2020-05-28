#!/usr/bin/env bash

# a setup to make the borders of neighbor tiling windows overlap

# the border width: (increase to make the effect more obvious)
w=5 # 1

# also try to make the borders between windows in different frames overlap:
# if this is activated (set to 1), then 
overlapBetweenFrames=1


if [[ $overlapBetweenFrames -eq 1 ]] ; then
    herbstclient set frame_gap -$w
else
    herbstclient set frame_gap 0
fi
herbstclient set frame_border_width 0
herbstclient set frame_padding $w
herbstclient set window_gap -$w
herbstclient set smart_frame_surroundings off
herbstclient set smart_window_surroundings off
herbstclient attr theme.tiling.border_width $w
herbstclient attr theme.tiling.inner_width 0
herbstclient attr theme.tiling.outer_width 0


