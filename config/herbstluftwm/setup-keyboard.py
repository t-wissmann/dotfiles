#!/usr/bin/env python3
import subprocess
import re
import sys

models = [
    {
        'name': 'pure kb talking 60%',
        'id': '04d9:0134',
        'usb_name': "Holtek Semiconductor, Inc. USB Keyboard",
        'options': ['compose:ralt', 'compose:rctrl', 'compose:rwin'],
    },
    {
        'name': 'thinkpad x1 keyboard',
        'id': '???',
        'usb_name': 'AT Translated Set 2 keyboard',
        'options': ['compose:prsc'],
    },
    {
        'name': 'progrestouch retro tiny (black 60% arrow keys)',
        'id': '2be8:0004',
        'usb_name': 'ARCHISS PTR66 ARCHISS PTR66',
        'options': ['compose:menu', 'compose:rctrl', 'ctrl:nocaps'],
    },
]

def log(log_line):
    print(log_line, file=sys.stderr)

def get_stdout(command):
    log(":: {}".format(' '.join(command)))
    proc = subprocess.run(command,
                          stdout=subprocess.PIPE,
                          universal_newlines=True)
    return proc.stdout

def query_usb_to_xinput_ids():
    # get xinput IDs of connected devices:
    xinput_ids = [x for x in get_stdout(['xinput', 'list', '--id-only']).splitlines()]
    # get their /dev/input/event.. filepath:
    prop_re = re.compile(r'\tDevice Node \(277\):\t"([^"]*)"$')
    section_re = re.compile(r"^Device '.*':")
    devices = []
    for line in get_stdout(['xinput', 'list-props'] + xinput_ids).splitlines():
        if section_re.match(line):
            devices.append(None)
            continue
        m = prop_re.match(line)
        if m:
            # replace the last 'None' by the actual input even path:
            devices[-1] = m.group(1)
    assert len(xinput_ids) == len(devices)

    # read usb vendor and model IDs from udev:
    # one usb device may create multiple xinput ids, so the following
    # is a dict to lists
    usb_to_xinput_ids = {}
    vendor_id_re = re.compile('ID_VENDOR_ID=([^\n]*)')
    model_id_re = re.compile('ID_MODEL_ID=([^\n]*)')
    for input_id, path in zip(xinput_ids, devices):
        if path is not None:
            udev_props = get_stdout(['udevadm', 'info', '--query=property', '--name=' + path])
            vendor = vendor_id_re.search(udev_props)
            model = model_id_re.search(udev_props)
            if model and vendor:
                usb_id = vendor.group(1) + ':' + model.group(1)
                if usb_id not in usb_to_xinput_ids:
                    usb_to_xinput_ids[usb_id] = []
                usb_to_xinput_ids[usb_id].append(input_id)
                # log(f'{usb_id} -> {input_id}')
    return usb_to_xinput_ids

def main():
    usb_to_xinput_ids = query_usb_to_xinput_ids()
    # clear existing keyboard options:
    get_stdout(['setxkbmap', '-option'])
    # set some default:
    global_options = [
        '-variant', 'altgr-intl',
        '-option', 'ctrl:nocaps', '-option', 'compose:menu',
    ]
    get_stdout(['setxkbmap', 'us'] + global_options)
    # go through all know 'models' and see whether they are connected:
    global models
    for known_kbd in models:
        ids = usb_to_xinput_ids.get(known_kbd['id'], [])
        if ids:
            log('Found "{}" on xinput {}'.format(known_kbd['name'], ' '.join(ids)))
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

