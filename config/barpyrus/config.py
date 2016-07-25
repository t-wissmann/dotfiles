from barpyrus import hlwm
from barpyrus import widgets as W
from barpyrus.core import Theme
from barpyrus import lemonbar
from barpyrus import conky
import sys
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

# An example conky-section:
# icons
bat_icons = [
    0xe242, 0xe243, 0xe244, 0xe245, 0xe246,
    0xe247, 0xe248, 0xe249, 0xe24a, 0xe24b,
]
# first icon: 0 percent
# last icon: 100 percent
bat_delta = 100 / len(bat_icons)
conky_text_title  = '%{F\\#B7CE42}%{T2}\ue026%{T-}%{F\\#CDCDCD} ${cpu}% '
conky_text_title += '%{F\\#6F99B4}%{T2}\ue021%{T-}%{F\\#CDCDCD} ${memperc}% '
conky_text_title += '%{F\\#FEA63C}%{T2}\ue13c%{T-}%{F\\#CDCDCD} ${downspeed enp0s25} '
conky_text_title += '%{F\\#D81860}%{T2}\ue13b%{T-}%{F\\#CDCDCD} ${upspeed enp0s25} '
conky_text_title += '%{F-}%{B-}'

#conky_sep = '%{T2}  %{T-}%{F\\#FEA63C}|%{T2} %{T-}'
#conky_sep = '%{T3}%{F\\#FEA63C}\ue1b1%{T-}'
conky_sep = '%{T3}%{F\\#878787}\ue1ac%{T2} %{T-}'
conky_text = ""
conky_text += conky_sep
conky_text += "${if_existing /sys/class/power_supply/BAT0}"
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
grey_frame = Theme(bg = '#de101010', fg = '#EFEFEF', padding = (3,3))
conky_widget = conky.ConkyWidget(conky_text_title)

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
        painter += '+'
    else:
        painter += '-'
    #painter.space(3)


# Widget configuration:
bar = lemonbar.Lemonbar(geometry = (x,y,width,height))
bar.widget = W.ListLayout([
    W.RawLabel('%{l}'),
    hlwm.HLWMTags(hc, monitor, tag_renderer = hlwm.underlined_tags),
    W.TabbedLayout(list(enumerate([
        hlwm.HLWMMonitorFocusLayout(hc, monitor,
            # this widget is shown on the focused monitor:
            hlwm.HLWMWindowTitle(hc, maxlen = 70),
            # this widget is shown on all unfocused monitors:
            conky_widget,
        ),
        conky_widget,
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


