from barpyrus import hlwm
from barpyrus import widgets as W
from barpyrus.core import Theme
from barpyrus import lemonbar
from barpyrus import conky
import sys
import os
# Copy this config to ~/.config/barpyrus/config.py

# set up a connection to herbstluftwm in order to get events
# and in order to call herbstclient commands
hc = hlwm.connect()

# get the geometry of the monitor
monitor = sys.argv[1] if len(sys.argv) >= 2 else 0
(x, y, monitor_w, monitor_h) = hc.monitor_rect(monitor)
height = 18 # height of the panel
width = monitor_w # width of the panel
gap = int(hc(['get', 'frame_gap'])) if 0 == int(hc(['get', 'smart_frame_surroundings'])) else 0
y += gap
x += gap
width -= 2 * gap
hc(['pad', str(monitor), str(height + gap)]) # get space for the panel

network_devices = os.listdir('/sys/class/net/')
network_devices = [ n for n in network_devices if n != "lo"]

cg = conky.ConkyGenerator(lemonbar.textpainter())
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
                    cg.case('match ${wireless_link_qual_perc %s} < %d}' % (net,(i+1)*wireless_delta))
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
conky_text += "%{T-}%{F\\#CDCDCD} $battery_percent%"
conky_text += "${endif}"
conky_text += "%{F-}"
conky_text += conky_sep
conky_text += '%{F\\#CDCDCD}${time %d. %B}'
conky_text += conky_sep
conky_text += '%{F\\#CDCDCD}'

# example options for the hlwm.HLWMLayoutSwitcher widget
xkblayouts = [
    'us us -variant altgr-intl us'.split(' '),
    'de de de'.split(' '),
]
setxkbmap = 'setxkbmap -option compose:menu -option ctrl:nocaps'
setxkbmap += ' -option compose:ralt -option compose:rctrl'

# you can define custom themes
grey_frame = Theme(fg = '#dedede', bg = '#454545', padding = (4,4))

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
        painter.fg('#9fbc00')
        painter.space(2)
        painter.symbol(0xe26f)
        painter.space(2)
    #painter.space(3)

conky_widget = conky.ConkyWidget(str(cg))

#barpyrus/windowframe.py
#xwin = windowframe.WindowFrame((x,y+20,width,height), 1);
#xwin.loop()

# Widget configuration:
bar = lemonbar.Lemonbar(geometry = (x,y,width,height), foreground='#CDCDCD')
bar.widget = W.ListLayout([
    W.RawLabel('%{l}'),
    hlwm.HLWMTags(hc, monitor, tag_renderer = hlwm.underlined_tags),
    W.TabbedLayout(list(enumerate([
        W.ListLayout([ W.RawLabel('%{c}'),
            hlwm.HLWMMonitorFocusLayout(hc, monitor,
                # this widget is shown on the focused monitor:
                grey_frame(hlwm.HLWMWindowTitle(hc, maxlen = 70)),
                # this widget is shown on all unfocused monitors:
                conky_widget,
            )]),
        W.ListLayout([ W.RawLabel('%{c}'), conky_widget ]),
    ])), tab_renderer = tab_renderer),
    W.RawLabel('%{r}'),
    # something like a tabbed widget with the tab labels '>' and '<'
    W.TabbedLayout([
        ('0', W.RawLabel('')),
        ('1', hlwm.HLWMLayoutSwitcher(hc, xkblayouts, command = setxkbmap.split(' '))),
        ], tab_renderer = zip_renderer),
    conky.ConkyWidget(text= conky_text),
    W.DateTime('%H:%M '),
])


