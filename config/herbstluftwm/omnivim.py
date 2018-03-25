#!/usr/bin/env python3

import subprocess

# vim bindings in any application

exit_omnivim = 'Escape'
keys = [
    ('h', 'Left'),
    ('j', 'Down'),
    ('k', 'Up'),
    ('l', 'Right'),
    ('Shift+4', 'Ctrl+E'),
    ('0', 'Home'),
    ('Ctrl+f', 'Next'),
    ('Ctrl+b', 'Prior'),
    ('b', 'Ctrl+Left'),
    ('f', 'Ctrl+Right'),
    ('w', 'Ctrl+Right'),
    #('/', 'Ctrl-f'),
]

bind_cmd = [
    'herbstclient',
    'chain',
]
bind_cmd_sep = 'NEXTKEY'
unbind_cmd = [ 'chain' ]
unbind_cmd_sep = 'UBNEXTKEY'
for k,m in keys:
    bind_cmd += [ bind_cmd_sep, 'keybind', k ]
    k_without_mods = k.split('-')[-1].split('+')[-1]
    cmd = [ 'xdotool', 'keyup', k_without_mods, 'key', '--clearmodifiers', m ]
    bind_cmd += [ 'spawn' ] + cmd
    unbind_cmd += [ unbind_cmd_sep, 'keyunbind', k ]

border_color = '#FF690C'
hlwm_themes = [
    'theme.tiling.active',
    'theme.floating.active',
]
for attr in hlwm_themes:
    # backup the color
    bind_cmd += [ bind_cmd_sep, \
                'try', 'new_attr', 'color', \
                attr + '.my_color_backup' ]
    bind_cmd += [ bind_cmd_sep, \
                'substitute', 'COLOR', \
                attr + '.color', \
                'set_attr', attr + '.my_color_backup', 'COLOR' ]
    bind_cmd += [ bind_cmd_sep, \
                'set_attr', attr + '.color', border_color ]
    unbind_cmd += [ unbind_cmd_sep, \
                'substitute', 'COLOR', \
                attr + '.my_color_backup', \
                'set_attr', attr + '.color', 'COLOR' ]

unbind_cmd += [ unbind_cmd_sep, 'keyunbind', exit_omnivim ]
#unbind_cmd += [ unbind_cmd_sep, 'spawn', 'notify-send', '-t', '1', 'VIM Bindings Inactive']

bind_cmd += [ bind_cmd_sep, 'keybind', exit_omnivim ]
bind_cmd += unbind_cmd

#print(' '.join(bind_cmd))
subprocess.call(bind_cmd)
#notify = ['notify-send', '-t', '1', 'VIM Bindings Active']
#print(subprocess.call(notify))

