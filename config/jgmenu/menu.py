#!/usr/bin/env python3

import argparse
import subprocess
import sys
import re
import os
import json
import socket

"""
A wrapper around jgmenu that allows

    1. easier configuration: submenus are just nested Menu() objects
    2. menus for PulseAudio-control
"""


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
    def parse_pactl_object_list(text):
        objects = {}
        cur_object_name = ''
        cur_object = {}
        property_re = re.compile('^\t([^\t:]*):[ ]?(.*)$')
        last_property = None
        cur_indent = ''

        for line in text.splitlines():
            if len(line) == 0:
                objects[cur_object_name] = cur_object
                cur_object = {}
                last_property = None
                continue

            if line[0] != '\t':
                cur_object_name = line
                continue

            m = property_re.match(line)
            if m:
                last_property = m.group(1)
                righthand = m.group(2)
                if len(righthand) == 0:
                    cur_object[last_property] = []
                else:
                    cur_object[last_property] = righthand
                    # the indent for continued attribute values:
                    # (the last ' ' is below the colon)
                    cur_indent = '\t' + len(last_property) * ' ' + ' '
                continue

            if line.startswith(cur_indent) and last_property is not None:
                cur_object[last_property] += line[len(cur_indent):]
                continue

            if last_property is not None and line.startswith('\t\t'):
                cur_object[last_property].append(line[2:])
                continue
            # else: skip

        if len(cur_object_name) > 0:
            objects[cur_object_name] = cur_object
        return objects

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
        objects = PulseAudio.parse_pactl_object_list(out)
        sink_name_re = re.compile('^Sink #([0-9]*)')
        sinks = []
        for name, obj in objects.items():
            m = sink_name_re.match(name)
            obj['id'] = m.group(1)
            sinks.append(obj)
        return sinks

    @staticmethod
    def list_sources():
        env = os.environ.copy()
        env['LC_ALL'] = 'C'
        out, err = subprocess.Popen(
            ['pactl', 'list', 'sources'],
            universal_newlines=True,
            stdout=subprocess.PIPE,
            env=env,
            ).communicate()
        objects = PulseAudio.parse_pactl_object_list(out)
        name_re = re.compile('^Source #([0-9]*)')
        sources = []
        for name, obj in objects.items():
            m = name_re.match(name)
            obj['id'] = m.group(1)
            sources.append(obj)
        return sources

    @staticmethod
    def sink_items():
        default_sink_name = PulseAudio.get_default_sink_name()
        entries = []
        all_sinks = PulseAudio.list_sinks()
        volume_percent_re = re.compile('([0-9]+)\%')
        for sink in all_sinks:
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

            use_this_cmd = [
                'pactl set-default-sink {}'.format(sink['id']),
            ]
            for other_sink in all_sinks:
                if other_sink['id'] == sink['id']:
                    muted = '0'
                else:
                    muted = '1'
                use_this_cmd.append('pactl set-sink-mute {} {}'.format(other_sink['id'], muted))

            current_volume = volume_percent_re.search(sink['Volume']).group(1)
            balance_command = 'pactl set-sink-volume {} {}%'.format(sink['id'], current_volume)

            use_this_cmd = ' && '.join(use_this_cmd)
            submenu = Menu('audio-sink-{}'.format(sink['id']), [
                Item('Use this and mute others', 'go-last', use_this_cmd),
                Item('Make default', 'forward', 'pactl set-default-sink {}'.format(sink['id'])),
                Item('Balance', 'reload', balance_command),
                mute_item,
            ])
            item_name = sink['Description'] + ' ({}%)'.format(current_volume)
            entries.append(Item(item_name, icon, submenu))

        return entries

    @staticmethod
    def source_items():
        #default_source_name = PulseAudio.get_default_source_name()
        volume_percent_re = re.compile('([0-9]+)\%')
        entries = []
        all_sources = PulseAudio.list_sources()
        for source in all_sources:
            if source['Monitor of Sink'] != 'n/a':
                # don't show monitors
                continue
            icon = 'audio-input-microphone'
            # icon = 'emblem-noread'
            mute_cmd = 'pactl set-source-mute {}'.format(source['id'])
            if source['Mute'] == 'yes':
                icon = 'remove'
                mute_cmd += ' 0'
                mute_item = Item('Unmute', 'audio-input-microphone', mute_cmd)
            else:
                mute_cmd += ' 1'
                mute_item = Item('Mute', 'remove', mute_cmd)

            current_volume = volume_percent_re.search(source['Volume']).group(1)
            item_name = source['Description'] + ' ({}%)'.format(current_volume)
            submenu = Menu('audio-source-{}'.format(source['id']), [
                mute_item,
                Item('Set to 100%', 'go-top', 'pactl set-source-volume {} 100%'.format(source['id'])),
                Item('Make default', 'forward', 'pactl set-default-source {}'.format(source['id'])),
            ])
            entries.append(Item(item_name, icon, submenu))
        return entries

# print(json.dumps(PulseAudio().list_sources(), indent=4, sort_keys=True))

def run_in_terminal(command):
    return "alacritty -e {}".format(command)

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

    maybe_netctl = []
    netctl_path = os.path.expanduser('~/dotfiles/menu/rofi-netctl')
    if socket.gethostname() == 'x1' and os.path.exists(netctl_path):
        maybe_netctl = [
            Item('Network', 'network-wired', netctl_path),
            Item('Docking Station', 'computer', run_in_terminal(os.path.expanduser('~/dotfiles/config/herbstluftwm/x1-docking-station.sh'))),
            Item('Bluetooth', 'bluetooth', 'blueman-applet'),
        ]
    menu = Menu('root', [
      Item('Thunar', 'system-file-manager', 'thunar'),
      Item('Audio', 'audio-card',
           Menu('audio', [
              Item('Pavucontrol', 'preferences-desktop', 'pavucontrol'),
              Sep(),
           ] + PulseAudio.sink_items() + [
              Sep(),
           ] + PulseAudio.source_items())),
      Item('xkill', 'edit-delete', 'xkill'),
      Sep(),
      Item('Dolphin', 'go-home', 'dolphin'),
      Item('Terminal', 'utilities-terminal', 'urxvt'),
      ] + maybe_netctl + [
      Sep(),
      Item('Qutebrowser', 'qutebrowser', 'qutebrowser'),
      Item('Firefox', 'web-browser', 'firefox'),
      Item('gedit', 'accessories-text-editor', 'gedit --standalone'),
      Item('KDE Connect', 'kdeconnect', 'killall kdeconnect-indicator ; kdeconnect-indicator '),
      Item('Telegram', 'telegram', 'killall telegram-desktop ; QT_QPA_PLATFORMTHEME= telegram-desktop'),
      # Item('Applications', 'start-here', XdgMenu()),
      Sep(),
      Item('Lock', 'lock', 'i3lock.sh'),
      Item('Screen off', 'xscreensaver', 'xset dpms force off'),
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
