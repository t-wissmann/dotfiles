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

unbind_cmd += [ unbind_cmd_sep, 'keyunbind', exit_omnivim ]
unbind_cmd += [ unbind_cmd_sep, 'spawn', 'notify-send', '-t', '1', 'VIM Bindings Inactive']

bind_cmd += [ bind_cmd_sep, 'keybind', exit_omnivim ]
bind_cmd += unbind_cmd

#print(' '.join(bind_cmd))
subprocess.call(bind_cmd)
notify = ['notify-send', '-t', '1', 'VIM Bindings Active']
print(subprocess.call(notify))

