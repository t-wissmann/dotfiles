#!/usr/bin/env python3

import argparse
import subprocess
import sys
import re
import os
import json


class Sep():
    def print(self, file):
        print('^sep()', file=file)


class Item():
    def __init__(self, title, icon, command):
        self.title = title
        self.icon = icon
        self.command = command

    def print(self, file):
        if isinstance(self.command, Menu):
            action = '^checkout({})'.format(self.command.get_submenu_id())
        else:
            action = self.command
        print('{}, {}, {}'.format(self.title, action, self.icon), file=file)


class Menu():
    used_submenus = []

    def __init__(self, identifier, entries):
        self.identifier = identifier
        self.entries = entries

    def get_submenu_id(self):
        Menu.used_submenus.append(self)
        return self.identifier

    def print(self, file):
        for item in self.entries:
            item.print(file)

    @staticmethod
    def print_submenus(file):
        for menu in Menu.used_submenus:
            print('', file=file)
            print('^tag({})'.format(menu.identifier), file=file)
            menu.print(file)


class XdgMenu(Menu):
    def __init__(self):
        Menu.__init__(self, 'xdg-application-menu', [])

    def print(self, file):
        out, err = subprocess.Popen(['jgmenu_run', 'pmenu'],
                                    universal_newlines=True,
                                    stdout=subprocess.PIPE).communicate()
        print(out, file=file)


class PulseAudio:
    @staticmethod
    def get_default_sink_name():
        out, err = subprocess.Popen(
            ['pactl', 'get-default-sink'],
            universal_newlines=True,
            stdout=subprocess.PIPE,
            ).communicate()
        return out.strip()

    @staticmethod
    def list_sinks():
        env = os.environ.copy()
        env['LC_ALL'] = 'C'
        out, err = subprocess.Popen(
            ['pactl', 'list', 'sinks'],
            universal_newlines=True,
            stdout=subprocess.PIPE,
            env=env,
            ).communicate()

        sinks = []
        cur_sink = {}
        sink_name_re = re.compile('^Sink #([0-9]*)')
        property_re = re.compile('^\t([^\t:]*):[ ]?(.*)$')
        last_property = None
        cur_indent = ''

        for line in out.splitlines():
            if len(line) == 0:
                sinks.append(cur_sink)
                cur_sink = {}
                last_property = None
            m = sink_name_re.match(line)
            if m:
                cur_sink['id'] = int(m.group(1))
                continue

            m = property_re.match(line)
            if m:
                last_property = m.group(1)
                righthand = m.group(2)
                if len(righthand) == 0:
                    cur_sink[last_property] = []
                else:
                    cur_sink[last_property] = righthand
                    # the indent for continued attribute values:
                    # (the last ' ' is below the colon)
                    cur_indent = '\t' + len(last_property) * ' ' + ' '
                continue

            if line.startswith(cur_indent) and last_property is not None:
                cur_sink[last_property] += line[len(cur_indent):]
                continue

            if last_property is not None and line.startswith('\t\t'):
                cur_sink[last_property].append(line[2:])
            # else: skip

        sinks.append(cur_sink)

        return sinks

    @staticmethod
    def sink_items():
        default_sink_name = PulseAudio.get_default_sink_name()
        entries = []
        for sink in PulseAudio.list_sinks():
            icon = ''
            if default_sink_name == sink['Name']:
                icon = 'audio-volume-high'
            if sink['Mute'] == 'yes':
                icon = 'audio-volume-muted'
                mute_item = Item(
                    'Unmute',
                    'audio-volume-high',
                    'pactl set-sink-mute {} 0'.format(sink['id']))
            else:
                mute_item = Item(
                    'Mute',
                    'audio-volume-muted',
                    'pactl set-sink-mute {} 1'.format(sink['id']))
            submenu = Menu('audio-sink-{}'.format(sink['id']), [
                Item('Use this and mute others', 'go-last', 'pactl set-default-sink {}'.format(sink['id'])),
                Item('Make default', 'forward', 'pactl set-default-sink {}'.format(sink['id'])),
                mute_item,
            ])
            entries.append(Item(sink['Description'], icon, submenu))

        return entries

# print(json.dumps(PulseAudio().list_sinks(), indent=4, sort_keys=True))

def main():
    parser = argparse.ArgumentParser(
        description='Config for jgmenu',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
        )
    parser.add_argument('--target',
                        choices=['jgmenu', 'stdout'],
                        default='stdout',
                        help='wether to pipe directly to jgmenu or print to stdout')
    args = parser.parse_args()

    menu = Menu('root', [
      Item('Dolphin', 'go-home', 'dolphin'),
      Item('Thunar', 'system-file-manager', 'thunar'),
      Item('Terminal', 'utilities-terminal', 'urxvt'),
      Sep(),
      Item('Qutebrowser', 'qutebrowser', 'qutebrowser'),
      Item('Firefox', 'web-browser', 'firefox'),
      Item('gedit', 'accessories-text-editor', 'gedit'),
      Item('Audio', 'audio-card',
           Menu('audio', [
              Item('Pavucontrol', 'preferences-desktop', 'pavucontrol'),
              Sep(),
           ] + PulseAudio.sink_items())),
      Item('Applications', 'start-here', XdgMenu()),
      Sep(),
      Item('Suspend', 'gnome-logout', 'systemctl suspend -i'),
    ])


    file = sys.stdout
    close_file = False
    proc = None
    if args.target == 'jgmenu':
        proc = subprocess.Popen(
            ['jgmenu', '--simple'],
            universal_newlines=True,
            stdin=subprocess.PIPE)
        file = proc.stdin
        close_file = True

    menu.print(file)
    menu.print_submenus(file)
    if close_file:
        file.close()
    if proc is not None:
        proc.wait()

if __name__ == '__main__':
    main()
