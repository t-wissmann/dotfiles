#!/usr/bin/env python3
"""
This calls setxkbmap for the connected xinput devices with
options that are configurable based on the device's vendor/model id or xinput
name.
"""


import subprocess
import re
import sys

caps2control = ['ctrl:nocaps']

models = [
    # all keyboards, with rising preference (later keyboards
    # possibly overwrite previous keyboards' options if multiple
    # keyboards are connected)
    {
        'name': 'thinkpad x1 keyboard',
        'id': '???',
        'xinput_name': 'AT Translated Set 2 keyboard',
        'options': ['compose:prsc'] + caps2control,
    },
    {
        'name': 'pure kb talking 60%',
        'id': '04d9:0134',
        'usb_name': "Holtek Semiconductor, Inc. USB Keyboard",
        'options': ['compose:ralt', 'compose:rctrl', 'compose:rwin'] + caps2control,
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
        'options': ['compose:ralt', 'compose:rwin'],
    },
    {
        'name': 'ibm/lenovo full width keyboard',
        'id': '04b3:3025',
        'options': ['compose:rwin', 'ctrl:nocaps', 'altwin:swap_alt_win'],
    },
]


def log(log_line):
    """log something to stderr"""
    print(log_line, file=sys.stderr)


def get_stdout(command):
    """execute a command and return its stdout"""
    # log(":: {}".format(' '.join(command)))
    proc = subprocess.run(command,
                          stdout=subprocess.PIPE,
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


def main():
    devices = xinput_devices()

    # clear existing keyboard options:
    get_stdout(['setxkbmap', '-option'])
    # set some default:
    global_options = [
        '-variant', 'altgr-intl',
        '-option', 'compose:menu',
    ]
    get_stdout(['setxkbmap', 'us'] + global_options)
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
                get_stdout(['setxkbmap', '-device', xinput_id] + options)


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
