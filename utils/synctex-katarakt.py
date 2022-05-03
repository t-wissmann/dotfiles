#!/usr/bin/env python3

# Dependencies (Debian/Ubuntu package names):
#
#   python3-gi
#   python3-dbus
#

# Thorsten Wißmann, 2021
# in case of bugs, contact:    edu _at_ thorsten-wissmann _dot_ de

import argparse
import sys
import subprocess
import time  # only for sleep()
import threading
import os
import os.path
import re  # for regular expressions
import dbus
import dbus.service
from gi.repository import GLib
from dbus.mainloop.glib import DBusGMainLoop


def debug(msg):
    print(':: ' + msg, file=sys.stderr)


def dbus_find_katarakt_with_pdf(bus, pdf_path):
    # using: https://github.com/zyga/dbus-python/blob/master/examples/list-system-services.py
    # Get a reference to the desktop bus' standard object, denoted
    # by the path /org/freedesktop/DBus.
    dbus_object = bus.get_object('org.freedesktop.DBus', '/org/freedesktop/DBus')
    # The object /org/freedesktop/DBus
    # implements the 'org.freedesktop.DBus' interface
    dbus_iface = dbus.Interface(dbus_object, 'org.freedesktop.DBus')
    services = dbus_iface.ListNames()
    service_re = re.compile(r'^katarakt\.pid([0-9]+)$')
    for service in services:
        m = service_re.match(service)
        if m:
            katrakt_pid = int(m.group(1))
            try:
                katarakt_dbus = bus.get_object(service, '/')
                katarakt_iface = dbus.Interface(katarakt_dbus, 'katarakt.SourceCorrelate')
                if katarakt_iface.filepath() == pdf_path:
                    return katrakt_pid, katarakt_iface
            except dbus.exceptions.DBusException:
                continue
    return None, None


def start_new_katarakt_instance(katarakt_cmd, bus, pdf_path):
    katarakt_booted = False

    proc = subprocess.Popen([katarakt_cmd, '--single-instance', 'false', pdf_path])
    while proc.pid is not None and not katarakt_booted:
        try:
            katarakt_serv = bus.get_object('katarakt.pid%d' % proc.pid, '/')
            katarakt_iface = dbus.Interface(katarakt_serv, 'katarakt.SourceCorrelate')
            return proc, katarakt_iface
        except dbus.exceptions.DBusException:
            time.sleep(0.01)
    return None, None


def start_katarakt_listener_for_pid(bus, katarakt_pid):
    bridge_name = f'katarakt.synctex.for_pid_{katarakt_pid}'
    try:
        # check if a bridge for the katarakt pid exists
        bus.get_object(bridge_name, '/')
        return None
    except dbus.exceptions.DBusException:
        # the bridge object just indicates that we are already listening
        # to signals from katarakt
        class KataraktListener(dbus.service.Object):
            def __init__(self, busName, object_path):
                dbus.service.Object.__init__(self, busName, object_path)

            @dbus.service.method(dbus_interface='katarakt.listener',
                                 in_signature='', out_signature='i')
            def Pid(self):
                return str(os.getpid())

        busName = dbus.service.BusName(bridge_name, bus=bus)
        return KataraktListener(busName, '/')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('TEX_FILE', help="The edited tex file")
    parser.add_argument('--editor-command',
                        help="The editor command that is passed over to synctex's -x flag; see 'synctex help edit'")
    parser.add_argument('--katarakt', help="The katarakt command",
                        metavar='katarakt', default='katarakt')
    parser.add_argument('--view-line', help="tex source line number to show in PDF",
                        type=int,
                        metavar='NUMBER')
    parser.add_argument('--synctex', help="The synctex command",
                        metavar='synctex', default='synctex')
    args = parser.parse_args()

    DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()
    bus = dbus.SessionBus()

    main_tex_file = args.TEX_FILE
    main_tex_file_name = os.path.splitext(main_tex_file)[0]
    pdf_path = os.path.abspath(main_tex_file_name + '.pdf')
    katarakt_pid, katarakt_iface = dbus_find_katarakt_with_pdf(bus, pdf_path)
    katarakt_proc = None
    if katarakt_iface:
        debug(f"Using existing katarkt instance with PID {katarakt_pid}")
    else:
        katarakt_proc, katarakt_iface = start_new_katarakt_instance(args.katarakt, bus, pdf_path)
        katarakt_pid = katarakt_proc.pid

    if args.view_line:
        subprocess.call([
            args.synctex, "view",
            "-i", f'{args.view_line}:0:{main_tex_file}',
            "-o", pdf_path,
            "-x", f'qdbus katarakt.pid{katarakt_pid} / katarakt.SourceCorrelate.view' +
                  ' %{output} %{page} %{x} %{y}'
        ])

    if args.editor_command:
        listener = start_katarakt_listener_for_pid(bus, katarakt_pid)
    else:
        listener = None

    # callback if the signal for edit is sent by katarakt
    def on_edit(filename, page, pdf_x, pdf_y):
        subprocess.call([
            args.synctex, "edit",
            "-o", f'{1 + page}:{pdf_x}:{pdf_y}:{filename}',
            "-x", args.editor_command,
            ])

    if listener is not None:
        debug(f"connecting to katarakt showing {katarakt_iface.filepath()}")
        katarakt_iface.connect_to_signal("edit", on_edit)

        def on_katarakt_exit(connection_name):
            try:
                # check if katarakt still runs:
                katarakt_iface.filepath()
            except dbus.exceptions.DBusException:
                # if the katarakt interface disappeared, quit as well:
                loop.quit()

        bus.watch_name_owner(f'katarakt.pid{katarakt_pid}', on_katarakt_exit)

        loop.run()

    # shutdown:
    if katarakt_proc is not None:
        katarakt_proc.terminate()
        katarakt_proc.wait()


main()
