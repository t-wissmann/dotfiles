from barpyrus import hlwm
from barpyrus import widgets as W
from barpyrus.core import Theme
from barpyrus import lemonbar
from barpyrus import conky
from barpyrus import trayer
from barpyrus import playerctl
import sys
import os
import subprocess
import socket

is_hidpi = socket.gethostname() in ['x1g5']
# Copy this config to ~/.config/barpyrus/config.py

# set up a connection to herbstluftwm in order to get events
# and in order to call herbstclient commands
hc = hlwm.connect()

# get the geometry of the monitor
monitor = sys.argv[1] if len(sys.argv) >= 2 else 0
(x, monitor_y, monitor_w, monitor_h) = hc.monitor_rect(monitor)
height = 18  # height of the panel
if is_hidpi:
    height = 28

width = monitor_w # width of the panel
gap = int(hc(['get', 'frame_gap']))  # if 'x1' == socket.gethostname() else 0
x += gap
width -= 2 * gap
top = True
if top:
    y = monitor_y + gap
    hc(['pad', str(monitor), str(height + gap)]) # get space for the panel
else:
    y = monitor_y + monitor_h - gap - height
    hc(['pad', str(monitor), "", "", str(height + gap)]) # get space for the panel

network_devices = os.listdir('/sys/class/net/')
network_devices = [ n for n in network_devices if n != "lo"]

def spawn_htop(button):
    subprocess.call(['urxvt', '-e', 'htop'])

cg = conky.ConkyGenerator(lemonbar.textpainter())
with cg.clickable([1], spawn_htop):
    with cg.temp_fg('#B7CE42'):
        cg.symbol(0xe026);
    cg += ' '; cg.var('cpu'); cg += '% '
    with cg.temp_fg('#6F99B4'):
        cg.symbol(0xe021);
    cg += ' '; cg.var('memperc'); cg += '% '

for net in network_devices:
    wireless_icons = [ 0xe218, 0xe219, 0xe21a ]
    wireless_delta = 100 / len(wireless_icons)
    with cg.if_('up %s' % net):
        cg.fg('#FEA63C')
        if net[0] == 'w':
            with cg.cases():
                for i,wicon in enumerate(wireless_icons[:-1]):
                    cg.case('match ${wireless_link_qual_perc %s} < %d' % (net,(i+1)*wireless_delta))
                    cg.symbol(wicon)
                cg.else_()
                cg.symbol(wireless_icons[-1]) # icon for 100 percent
        else:
            cg.symbol(0xe197) # normal wired icon
        cg.fg('#D81860') ; cg.symbol(0xe13c) ; cg.fg('#CDCDCD') ; cg.var('downspeed %s' % net)
        cg.fg('#D81860') ; cg.symbol(0xe13b) ; cg.fg('#CDCDCD') ; cg.var('upspeed %s' % net)
cg.drawRaw('%{F-}%{B-}')


# An example conky-section:
# icons
bat_icons = [
    0xe242, 0xe243, 0xe244, 0xe245, 0xe246,
    0xe247, 0xe248, 0xe249, 0xe24a, 0xe24b,
]

# first icon: 0 percent
# last icon: 100 percent
bat_delta = 100 / len(bat_icons)

#conky_sep = '%{T2}  %{T-}%{F\\#FEA63C}|%{T2} %{T-}'
#conky_sep = '%{T3}%{F\\#FEA63C}\ue1b1%{T-}'
conky_sep = '%{T3}%{F\\#878787}\ue1ac%{T2} %{T-}'
# if is_hidpi:
#     conky_sep = '%{T3}%{F\\#878787} / %{T2} %{T-}'
conky_text = ""
conky_text += "${if_existing /sys/class/power_supply/BAT0}"
conky_text += conky_sep
conky_text += "%{T2}"
conky_text += "${if_match \"$battery\" == \"discharging $battery_percent%\"}"
conky_text += "%{F\\#FFC726}"
conky_text += "$else"
conky_text += "%{F\\#9fbc00}"
conky_text += "$endif"
for i,icon in enumerate(bat_icons[:-1]):
    conky_text += "${if_match $battery_percent < %d}" % ((i+1)*bat_delta)
    conky_text += chr(icon)
    conky_text += "${else}"
conky_text += chr(bat_icons[-1]) # icon for 100 percent
for _ in bat_icons[:-1]:
    conky_text += "${endif}"
conky_text += "%{T-}"
conky_text += "${if_match $battery_percent < 8}%{B\\#57000F}%{F\\#FF7F27}${else}"
conky_text += "${if_match $battery_percent < 15}%{F\\#FF7F27}${else}"
conky_text += "%{F\\#CDCDCD}${endif}${endif}"
# format_time only works if times_in_seconds is activated
conky_text += " $battery_percent% ${if_empty $battery_time}${else}(${format_time $battery_time \"\\hh\\mm\"})${endif}"
conky_text += "${endif}" # endif: if BAT0 exists
conky_text += "%{B-}%{F-}"
conky_text += conky_sep

if os.path.exists('/proc/acpi/ibm/thermal'):
    conky_text += '%{F\\#FF3E33}'
    conky_text += "${if_match ${ibm_temps 0} > 44}%{B\\#980000}${endif}"
    conky_text += chr(0xe0a4)
    conky_text += '%{F\\#CDCDCD}'
    # conky_text += chr(0xe0a5)
    conky_text += '${ibm_temps 0}°%{B-}'
    conky_text += conky_sep

conky_text += '%{F\\#CDCDCD}${time %d. %B \'%y}'
conky_text += conky_sep
conky_text += '%{F\\#CDCDCD}'

# example options for the hlwm.HLWMLayoutSwitcher widget
xkblayouts = [
    'us us -option compose:ralt -variant altgr-intl us'.split(' '),
    'de de de'.split(' '),
]
setxkbmap = 'setxkbmap -option -option compose:menu -option ctrl:nocaps'
setxkbmap += ' -option compose:rctrl'

def simple_tag_renderer(self, painter): # self is a HLWMTagInfo object
    self.activecolor = '#86AB5F'
    if self.empty:
        return
    #painter.ol('#ffffff' if self.focused else None)
    painter.set_flag(painter.underline, True if self.visible else False)
    painter.fg('#a0a0a0' if self.occupied else '#909090')
    ol = None
    if self.urgent:
        ol = '#FF7F27'
        painter.fg('#FF7F27')
        painter.set_flag(painter.underline, True)
        painter.bg('#57000F')
    elif self.here:
        painter.fg('#ffffff')
        ol = self.activecolor if self.focused else '#ffffff'
        painter.bg(self.emphbg)
    else:
        painter.bg('#101010')
        ol = '#454545'
    painter.ol(ol)

    painter.space(1 if is_hidpi else 3)
    name2icon = {
        'irc': 0xe1ef,
        'vim': 0xe1cf,
        'web': 0xe19c,
        'mail': 0xe071,
        'scratchpad': 0xe022,
        'music': 0xe05c,
    }
    index_str = str(self.index + 1)
    if index_str != self.name:
        painter += index_str
        painter.space(1 if is_hidpi else 3)
    if self.name in name2icon and not is_hidpi:
        painter.symbol(name2icon[self.name])
    else:
        painter += self.name
    painter.space(1 if is_hidpi else 3)
    painter.bg()
    painter.ol()
    painter.set_flag(painter.underline, False)
    painter.space(1 if is_hidpi else 2)


# you can define custom themes
grey_frame = Theme(fg = '#dedede', bg = '#454545', padding = (4,4))
if is_hidpi:
    def identity(x):
        return x
    grey_frame = identity

def tab_renderer(self, painter):
    painter.fg('#989898')
    painter.symbol(0xe1aa)
    #painter.fg('#FEA63C')
    #painter.symbol(0xe1b1)
    painter.fg('#D81860')
    painter.symbol(0xe12f)
    #painter.fg('#FEA63C')
    #painter.symbol(0xe1b1)
    painter.fg('#989898')
    painter.symbol(0xe1aa)
    painter.fg('#CDCDCD')
    painter.space(3)

def zip_renderer(self, painter):
    painter.fg('#989898')
    if self.label == '0':
        painter.symbol(0xe26f)
        painter.space(2)
    else:
        painter.bg('#303030')
        painter.fg('#86AB5F')
        painter.space(2)
        painter.symbol(0xe26f)
        painter.space(2)
    #painter.space(3)

conky_widget = conky.ConkyWidget(cg)

#barpyrus/windowframe.py
#xwin = windowframe.WindowFrame((x,y+20,width,height), 1);
#xwin.loop()

# Widget configuration:
panel_geometry = (x,y,width,height)
lemonbar_options = {
    'geometry': panel_geometry,
    'foreground': '#CDCDCD',
    'background': '#CC101010',
}

if is_hidpi:
    lemonbar_options['font'] = 'Bitstream Vera Sans Mono:size=8'
    lemonbar_options['font'] = 'Source Code Pro:size=8'
    lemonbar_options['symbol_font'] = \
        '-wuncon-siji-medium-r-normal--10-100-75-75-c-80-iso10646-1'
    lemonbar_options['spacing_font'] = (0.5, 'Dejavu Sans:size=1')
    lemonbar_options['symbol_vert_offset'] = 4
    tag_renderer = simple_tag_renderer
else:
    tag_renderer = simple_tag_renderer
    # tag_renderer = hlwm.underlined_tags
    # tag_renderer.activecolor = 'red'

def run_gdmflexi(button):
    cmd = ['urxvt']
    cmd = ['gdmflexiserver']
    os.spawnvpe(os.P_NOWAIT, cmd[0], cmd, os.environ)

gdmflexiserver = W.RawLabel('')
# if socket.gethostname() == 'hoth':
#     gdmflexiserver = W.Button('[Nutzer Wechseln] ')
#     gdmflexiserver.callback = run_gdmflexi


class Jgmenu(W.Widget):
    def __init__(self):
        super(Jgmenu,self).__init__()
        self.buttons = [ 1 ]

    def render(self, painter):
        painter.bg('#243423')
        painter.fg('#efefef')
        if is_hidpi:
            painter.space(1)
        painter.symbol(0xe142)  # ghost
        painter.space(2)
        painter.bg(None)
        painter.space(2)
        painter.fg('#878787')
        painter.symbol(0xe1aa)  # separator
        painter.space(2)

    def on_click(self, button):
        menu = os.path.expanduser('~/.config/jgmenu/menu.py')
        cmd = [menu, '--target=jgmenu']
        os.spawnvpe(os.P_NOWAIT, cmd[0], cmd, os.environ)


bar = lemonbar.Lemonbar(**lemonbar_options)

if int(monitor) == 0:
    args = [
        #'--background', '#101010',
        '-t',
        '--tint-color', '#101010',
        '--tint-level', str(0xCC),
    ]
    if is_hidpi:
        factor = 0.27  # found out by experiement
    else:
        factor = 1
    maybe_systray = [
        #W.RawLabel('%{F' + bgcolor + '}' + chr(0xe1ab) + '%{B' + bgcolor + '}'),
        W.RawLabel('%{T3}%{F#878787}\ue1ac%{T2}%{T-}'),
        trayer.StalonetrayWidget(panel_geometry,
                                 args=args,
                                 width_factor=factor),
        W.RawLabel('%{B-}'),
    ]
else:
    maybe_systray = []

if socket.gethostname() == 'x1':
    center_widget = W.ListLayout([ W.RawLabel('%{c}'), conky_widget ])
else:
    center_widget = W.TabbedLayout(list(enumerate([
        W.ListLayout([ W.RawLabel('%{c}'),
            hlwm.HLWMMonitorFocusLayout(hc, monitor,
                # this widget is shown on the focused monitor:
                # grey_frame(hlwm.HLWMWindowTitle(hc, maxlen = 70)),
                playerctl.Playerctl(),
                # this widget is shown on all unfocused monitors:
                conky_widget,
            )]),
        W.ListLayout([ W.RawLabel('%{c}'), conky_widget ]),
    ])), tab_renderer = tab_renderer)

bar.widget = W.ListLayout([
    W.RawLabel('%{l}'),
    Jgmenu(),
    hlwm.HLWMTags(hc, monitor, tag_renderer = tag_renderer),
    center_widget,
    W.RawLabel('%{r}'),
    gdmflexiserver,
    # # something like a tabbed widget with the tab labels '>' and '<'
    # W.TabbedLayout([
    #     ('0', W.RawLabel('')),
    #     ('1', hlwm.HLWMLayoutSwitcher(hc, xkblayouts, command = setxkbmap.split(' '))),
    #     ], tab_renderer = zip_renderer),
    conky.ConkyWidget(text=conky_text, config={'times_in_seconds': 'true'}),
    W.DateTime('%H:%M'),
    # W.DateTime('%H:%M', timezone='Europe/Berlin'),
    # W.DateTime(' / %H:%M ', timezone='Europe/Tallinn'),
] + maybe_systray)


