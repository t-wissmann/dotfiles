#!/usr/bin/env python3
# vim: ft=python

# see https://developer.gnome.org/notification-spec/

import dbus.service
#import dbus.glib
import gi
from gi.repository import GLib
import dbus
from dbus.mainloop.glib import DBusGMainLoop
import sys
import subprocess
import re
from time import sleep

def fail(msg):
    print('{} error: {}'.format(sys.argv[0], msg), file=sys.stderr)
    sys.exit(1)

item = 'org.freedesktop.Notifications'
path = '/org/freedesktop/Notifications'
interface = 'org.freedesktop.Notifications'


DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
loop = GLib.MainLoop()

ACTION_TYPE = 'type'
ACTION_SKIP = 'skip'

STEP_USER = 'user'
STEP_PASSWORD = 'pw'

notif = bus.get_object(item, path)
notify = dbus.Interface(notif, interface)
capabilities = notify.GetCapabilities()

hint = { }
dialog_id = None
callback = None

def type_string(string):
    subprocess.Popen(['xdotool', 'type', string]).wait()

def read_pass_entry(filename):
    p = subprocess.Popen(['pass', 'show', filename], stdout=subprocess.PIPE)
    out,_ = p.communicate()
    if p.wait() != 0:
        return None
    lines = out.decode().splitlines()
    user_re = re.compile('^user(name|): (.*)$', re.IGNORECASE)
    username = None
    for l in lines[1:]:
        m = user_re.match(l)
        if m:
            username = m.group(2)
    return username, lines[0]

filename = sys.argv[1]
entry = read_pass_entry(filename)
if entry is None:
    sys.exit(1)
username, password = entry

if not 'actions' in capabilities:
    fail('Notify server does not support ')

def step_ask_user():
    global dialog_id
    global callback
    title = 'Type username »{}«?'.format(username)
    body = 'Typing credentials from {}'.format(filename)
    actions = [
        ACTION_SKIP, 'Skip',
        ACTION_TYPE, 'Type',
    ]
    dialog_id = notify.Notify("pass-autotype", 0, '', title, body, actions, hint, 0)
    callback = step_answer_user

def step_answer_user(para):
    if para == ACTION_TYPE:
        type_string(username + '\t')
        step_ask_password()
    if para == ACTION_SKIP:
        step_ask_password()

def step_ask_password():
    global dialog_id
    global callback
    title = 'Type password?'
    body = 'Typing credentials from {}'.format(filename)
    actions = [
        ACTION_TYPE, 'Type',
    ]
    dialog_id = notify.Notify("pass-autotype", 0, '', title, body, actions, hint, 0)
    callback = step_answer_password

def step_answer_password(para):
    if para == ACTION_TYPE:
        type_string(password)
    loop.quit()

def on_action(cur_dialog_id, action_str):
    global dialog_id
    global callback
    if dialog_id == cur_dialog_id:
        callback(action_str)

def on_close(cur_dialog_id, reason):
    if dialog_id == cur_dialog_id:
        loop.quit()

notify.connect_to_signal("NotificationClosed", on_close)
notify.connect_to_signal("ActionInvoked", on_action)
if username is None:
    step_ask_password()
else:
    step_ask_user()
loop.run()


