#!/usr/bin/env python3
"""
This calls setxkbmap for the connected xinput devices with
options that are configurable based on the device's vendor/model id or xinput
name.
"""


import subprocess
import re
import sys
import os
import argparse

caps2control = ['ctrl:nocaps']

default_layout = os.path.expanduser('~/.config/herbstluftwm/xkb/symbols/eu-hjkl')
# default_layout = 'eu'

global_options = [
        # '-variant', 'altgr-intl',
        '-option', 'compose:menu',
]


models = [
    # all keyboards, with rising preference (later keyboards
    # possibly overwrite previous keyboards' options if multiple
    # keyboards are connected)
    {
        'name': 'thinkpad x1 keyboard',
        'id': '???',
        'xinput_name': 'AT Translated Set 2 keyboard',
        'options': ['compose:prsc', 'lv3:ralt'] + caps2control,
    },
    {
        'name': 'pure kb talking 60%',
        'id': '04d9:0134',
        'usb_name': "Holtek Semiconductor, Inc. USB Keyboard",
        'options': ['compose:rctrl', 'compose:rwin'] + caps2control,
    },
    {
        'name': 'progrestouch retro tiny (black 60% arrow keys)',
        'id': '2be8:0004',
        'usb_name': 'ARCHISS PTR66 ARCHISS PTR66',
        'options': ['compose:menu', 'compose:rctrl'] + caps2control,
    },
    {
        'name': 'PS/2 keyboard via USB adapter',
        'id': '0a81:0205',
        'usb_name': 'Chesen Electronics Corp. PS/2 Keyboard+Mouse Adapter',
        'options': ['compose:ralt', 'compose:rwin'] + caps2control,
    },
    {
        'name': 'HHKB Lite2',
        'id': '04fe:0006',
        'usb_name': 'PFU, Ltd Happy Hacking Keyboard Lite2',
        'options': [
            'lv3:rwin_switch', 'compose:ralt',  # swap right win and alt
        ],
    },
    {
        'name': 'HHKB Pro2',
        'id': '0853:0100',
        'usb_name': 'Topre Corporation HHKB Professional',
        'options': [
            'lv3:rwin_switch', 'compose:ralt',  # swap right win and alt
        ],
    },
    # {
    #     'name': 'ibm/lenovo full width keyboard',
    #     'id': '04b3:3025',
    #     'options': ['compose:rwin', 'ctrl:nocaps', 'altwin:swap_alt_win'],
    # },
]


def log(log_line):
    """log something to stderr"""
    print(log_line, file=sys.stderr)


def get_stdout(command, stdin=None):
    """execute a command and return its stdout"""
    if hasattr(get_stdout, 'verbose') and get_stdout.verbose:
        log(":: {}".format(' '.join(command)))
    proc = subprocess.run(command,
                          stdout=subprocess.PIPE,
                          input=stdin,
                          universal_newlines=True)
    return proc.stdout


class XInputDevice:
    """Metadata of an connected XInput device
    """
    def __init__(self, id_, name):
        self.id = id_
        self.name = name
        self.vendor_id = None
        self.model_id = None
        self.event_path = None  # /dev/input/eventX
        self.input_type = None  # master/slave pointer/keyboard

    def usb_id(self):
        """a device ID as listed in lsusb"""
        if self.vendor_id is not None and self.model_id is not None:
            return '{}:{}'.format(self.vendor_id, self.model_id)
        return None


def xinput_devices():
    """return a list of all xinput devices with additional
    information about the event path and vendor/model ids"""
    # get xinput IDs of connected devices:
    xinput_ids = []
    id2type = {}
    id_line_re = re.compile(r'.*\tid=([0-9]*)\t\[(.*) \([0-9]*\)\]')
    _RE_COMBINE_WHITESPACE = re.compile(r"\s+")
    for line in get_stdout(['xinput', 'list']).splitlines():
        m = id_line_re.match(line)
        if m:
            cur_id = m.group(1)
            cur_type = _RE_COMBINE_WHITESPACE.sub(" ", m.group(2)).strip()
            xinput_ids.append(cur_id)
            id2type[cur_id] = cur_type

    # get their /dev/input/event.. filepath:
    path_re = re.compile(r'\tDevice Node \([0-9]*\):\t"([^"]*)"$')
    section_re = re.compile(r"^Device '(.*)':$")
    devices = []
    for line in get_stdout(['xinput', 'list-props'] + xinput_ids).splitlines():
        m = section_re.match(line)
        if m:
            # create a new device object with the name from the section
            devices.append(XInputDevice('unknown_id', m.group(1)))
            continue
        m = path_re.match(line)
        if m:
            # set the event path in the last device created:
            devices[-1].event_path = m.group(1)
    assert len(xinput_ids) == len(devices)
    for xid, dev in zip(xinput_ids, devices):
        dev.id = xid
        dev.input_type = id2type[xid]

    # read usb vendor and model IDs from udev:
    udev_cmd = ['udevadm', 'info']
    devices_in_udev = []  # devices in the udevadm output
    for dev in devices:
        if dev.event_path is not None:
            devices_in_udev.append(dev)
            udev_cmd += ['--query=property', '--name=' + dev.event_path]
    dev_idx = -1
    cur_dev = None
    for line in get_stdout(udev_cmd).splitlines():
        name, value = line.split('=', 1)
        name = name.upper()
        if name == 'DEVPATH':
            # every section should start with DEVPATH
            dev_idx += 1
            cur_dev = devices_in_udev[dev_idx]
        elif name == 'DEVNAME':
            # DEVNAME=/dev/input/eventXX should come second:
            assert cur_dev.event_path == value
        elif name == 'ID_VENDOR_ID':
            cur_dev.vendor_id = value
        elif name == 'ID_MODEL_ID':
            cur_dev.model_id = value

    return devices

def setxkbmap_layout_file(layout_name_or_path, setxkbmap_options, xinput_id=None):
    if '/' not in layout_name_or_path:
        # a plain setxkbmap suffices:
        setxkbmap_cmd = ['setxkbmap']
        if xinput_id is not None:
            setxkbmap_cmd += ['-device', xinput_id]
        setxkbmap_cmd += [layout_name_or_path] + setxkbmap_options
        get_stdout(setxkbmap_cmd)
    else:
        path_re = r'^(.*)/symbols/[^/]*'
        assert re.match(path_re, layout_name_or_path), \
            'layout file must sit below a symbols directory (otherwise, xkbcomp will not find it)'
        directory = re.match(path_re, layout_name_or_path).group(1)
        layout_name = os.path.basename(layout_name_or_path)
        xkb_keymap = get_stdout(['setxkbmap', layout_name, '-print'] + setxkbmap_options)
        xkbcomp_cmd = ['xkbcomp']
        if xinput_id is not None:
            xkbcomp_cmd += ['-i', xinput_id]
        xkbcomp_cmd += ['-w', '0', f'-I{directory}', '-', os.environ['DISPLAY']]
        get_stdout(xkbcomp_cmd, stdin=xkb_keymap)

def main():
    devices = xinput_devices()
    parser = argparse.ArgumentParser()
    parser.add_argument('--verbose', default=False, action='store_true', help='show commands that are run')
    args = parser.parse_args()

    get_stdout.verbose = args.verbose


    # clear existing keyboard options:
    get_stdout(['xdotool', 'key', '--clearmodifiers', ''])
    get_stdout(['setxkbmap', '-option'])
    # set some default:
    global global_options, default_layout
    setxkbmap_layout_file(default_layout, global_options)
    # go through all know 'models' and see whether they are connected.
    # if so, apply the specified options:
    global models
    for known_kbd in models:
        devs = [d for d in devices if d.usb_id() == known_kbd['id']]
        if not devs and 'xinput_name' in known_kbd:
            # look for name:
            devs = [d for d in devices if d.name == known_kbd['xinput_name']]
        if devs:
            ids = [d.id for d in devs if d.input_type == 'slave keyboard']
            log('==> Found keyboard "{}" on xinput {}'
                .format(known_kbd['name'], ' '.join(ids)))
            options = []
            for arg in known_kbd['options']:
                options += ['-option', arg]
            for xinput_id in ids:
                # get_stdout(['setxkbmap', '-device', xinput_id] + options)
                setxkbmap_layout_file(default_layout, options, xinput_id=xinput_id)


main()

# old code:
# has-kbd() {
#     lsusb | grep "ID $*" > /dev/null
# }
#
# hc keyunbind --all
#
# keyboard=
# if has-kbd 04d9:0134 Holtek Semiconductor ; then # pure kbtalking
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rwin
# elif has-kbd 04d9:0112 Holtek Semiconductor ; then # kbparadise V60 Mini
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:rwin
#     keyboard=v60mini
# elif has-kbd 2be8:0004 ; then # Progres Touch Retro Tiny
#     setxkbmap us -variant altgr-intl -option compose:rctrl -option ctrl:nocaps
# elif false ; then # mac
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rctrl
#     xmodmap -e 'keycode any 94 = grave'
# elif [[ $HOSTNAME == x1 ]] ; then
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:prsc
# else
#     setxkbmap us -variant altgr-intl -option compose:menu -option ctrl:nocaps -option compose:ralt -option compose:rwin
# fi
