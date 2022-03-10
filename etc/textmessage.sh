#!/bin/bash

# in order to use this, create something like this in /etc/textmessage.sh
# and also copy the textmessage files to /etc/initcpio/

# Then, add the 'textmessage' hook to the HOOKS array in /etc/mkinitcpio.conf
# Be sure to put it before block and encrypt hooks

echo 'This is a welcome message'


