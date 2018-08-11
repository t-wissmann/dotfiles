#!/usr/bin/env python3

# based on https://askubuntu.com/a/184046/547950

import dbus      # for dbus communication (obviously)
import gobject   # main loop
from dbus.mainloop.glib import DBusGMainLoop # integration into the main loop
import sys
import subprocess

def handle_resume_callback(start):
    if start:
        subprocess.call(sys.argv[1:])
    #print("start == " + str(start))

DBusGMainLoop(set_as_default=True) # integrate into main loob
bus = dbus.SystemBus()             # connect to dbus system wide
bus.add_signal_receiver(           # defince the signal to listen to
    handle_resume_callback,            # name of callback function
    'PrepareForSleep',                        # signal name
    'org.freedesktop.login1.Manager',          # interface
    'org.freedesktop.login1',           # bus name
    path='/org/freedesktop/login1',
)

loop = gobject.MainLoop()          # define mainloop
loop.run()                         # run main loop
