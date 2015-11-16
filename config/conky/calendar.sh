#!/bin/bash

# Prints a calendar, colorized using conky's color instructions
# Use this using the ${execpi}-variable in conky's config.

remind -b1 -c+2 -w80 ~/.reminders.d/master \
    | sed 's,[-+|]\+,${color1}&${color}${outlinecolor},g' \
    | sed 's,[│─┤┐┘└┌├┴┼┬]\+,${color1}&${color}${outlinecolor},g' \
    | sed 's,[A-Za-z0-9 ]*[*]\+,${color FF6A63}&${color},g'
