#!/usr/bin/env python3

import re
import os.path
from PyQt5.QtCore import QUrl
from qutebrowser.api import interceptor
from qutebrowser.api import message
import qutebrowser
from qutebrowser.misc.objects import commands

config.load_autoconfig()

c.editor.command = 'alacritty -e nvim {}'.split(' ')
c.auto_save.session = True
c.content.user_stylesheets = [ '~/.config/qutebrowser/style.css' ]
c.downloads.remove_finished = 0
c.statusbar.position = 'top'
c.statusbar.padding = {
    'top': 3,
    'bottom': 2,
    'left': 1,
    'right': 1,
}

# c.qt.force_software_rendering = 'qt-quick'

c.input.insert_mode.auto_enter = True
c.input.insert_mode.auto_leave = False
c.input.insert_mode.auto_load = True
c.input.insert_mode.plugins = True

c.content.headers.accept_language = 'de-DE,en-US,en'
c.content.geolocation = False
c.content.blocking.whitelist = ["piwik.org", "partners.webmasterplan.com", "track.webgains.com", "www.googleadservices.com"]

c.completion.web_history.max_items = 500
c.completion.shrink = True
c.completion.show = 'auto'


c.tabs.background = True
c.tabs.last_close = 'blank'
c.tabs.show = 'multiple'


c.tabs.title.alignment = 'center'
c.tabs.title.format = '{index} | {audio} {current_title}'
c.tabs.padding = {
    'top': 2,
    'bottom': 2,
    'left': 0,
    'right': 5
}
c.tabs.max_width = 200
c.tabs.indicator.width = 1
c.tabs.indicator.padding = {
    'top': 1,
    'bottom': 1,
    'left': 0,
    'right': 4,
}

c.downloads.location.directory = '~/downloads/'
c.downloads.location.prompt = False

c.scrolling.bar = 'always'
c.scrolling.smooth = True

c.hints.border = '1px solid black'
c.hints.mode = 'number'
c.hints.chars = '12345'
c.hints.uppercase = True

c.url.searchengines['google'] = 'https://encrypted.google.com/search?q={}'
c.url.searchengines['g'] = c.url.searchengines['google']
c.url.searchengines['gl'] = 'https://encrypted.google.com/search?btnI=1&q={}&sourceid=navclient&gfns=1'
c.url.searchengines['DEFAULT'] = c.url.searchengines['google']
c.url.searchengines['gimg'] = 'http://www.google.de/search?tbm=isch&hl=de&source=hp&q={}'
c.url.searchengines['doi2bib'] = 'https://doi2bib.org/bib/{}'

c.url.searchengines['duckduckgo'] = 'https://duckduckgo.com/?q={}'
c.url.searchengines['d'] = c.url.searchengines['duckduckgo']

c.url.searchengines['h'] = 'http://www.google.com/search?btnI=1&q=hackage%20{}'
c.url.searchengines['wikipedia'] = 'http://en.wikipedia.org/w/index.php?title=Special:Search&search={}'
c.url.searchengines['wiki'] = 'http://de.wikipedia.org/w/index.php?title=Special:Search&search={}'
c.url.searchengines['wikien'] = 'http://en.wikipedia.org/w/index.php?title=Special:Search&search={}'
c.url.searchengines['wiki-en'] = 'http://en.wikipedia.org/w/index.php?title=Special:Search&search={}'
c.url.searchengines['wen'] = 'http://en.wikipedia.org/w/index.php?title=Special:Search&search={}'
c.url.searchengines['wetter'] = 'http://www.wetter.de/suche.html?search={}'
c.url.searchengines['dict'] = 'http://www.dict.cc/?s={}'
c.url.searchengines['nlabsearch'] = 'http://ncatlab.org/nlab/search?&query={}'
c.url.searchengines['nlab'] = 'http://ncatlab.org/nlab/show/{}'
c.url.searchengines['nlabold'] = 'file:///home/thorsten/.config/qutebrowser/nlab-search-or-show.html?q={}'
c.url.searchengines['tab'] = 'http://www.guitaretab.com/fetch/?type=tab&query={}'
c.url.searchengines['latein'] = 'http://www.frag-caesar.de/lateinwoerterbuch/{}-uebersetzung.html'
c.url.searchengines['aur'] = 'https://aur.archlinux.org/packages?O=0&SeB=nd&K={}&outdated=&SB=p&SO=d&PP=50&submit=Go'
c.url.searchengines['archde'] = 'https://wiki.archlinux.de/index.php?search={}&go=Seite'
c.url.searchengines['arch'] = 'http://wiki.archlinux.org/index.php/{}'
c.url.searchengines['leo'] = 'http://dict.leo.org/ende?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=&search={}'
c.url.searchengines['youtube'] = 'http://www.youtube.com/results?search_query={}'
c.url.searchengines['yt'] = c.url.searchengines['youtube']
c.url.searchengines['gpg'] = 'http://gpg-keyserver.de/pks/lookup?search=0x{}&op=vindex'
c.url.searchengines['27c3-phone'] = 'http://www.eventphone.de/guru2/phonebook?event=27C3&s={}&installedonly=0&submit=Search'
c.url.searchengines['27c3'] = 'https://events.ccc.de/congress/2010/wiki/Special:Search?search={}'
c.url.searchengines['hoogle'] = 'http://haskell.org/hoogle/?hoogle={}'
c.url.searchengines['github'] = 'https://github.com/search?utf8=%E2%9C%93&q={}'
#c.url.searchengines['gh'] = 'https://github.com/{literal}'
c.url.searchengines['gh2'] = 'https://github.com/{}'
#c.url.searchengines['gh3'] = 'https://github.com/{quoted}'
c.url.searchengines['map'] = 'http://openstreetmap.org/search?query={}'
c.url.searchengines['discogs'] = 'http://www.discogs.com/search/?q={}&type=release'
c.url.searchengines['maps'] = c.url.searchengines['map']
c.url.searchengines['osm'] = c.url.searchengines['map']
c.url.searchengines['amazon'] = 'http://www.amazon.de/s?k={}'
c.url.searchengines['duden'] = 'http://www.duden.de/suchen/dudenonline/{}'
c.url.searchengines['python'] = 'file:///usr/share/doc/python/html/search.html?q={}&check_keywords=yes&area=default'
c.url.searchengines['jpc'] = 'https://www.jpc.de/s/{}'  # TODO: replace by {quoted}
c.url.searchengines['kanji'] = 'https://en.wiktionary.org/wiki/{}#Japanese'
c.url.searchengines['jp'] = 'https://www.wadoku.de/search/{}'
c.url.searchengines['doi'] = 'https://dx.doi.org/{}'
c.url.searchengines['imdb'] = 'https://www.imdb.com/find?q={}&ref_=nv_sr_sm'
c.url.searchengines['dictnl'] = 'https://denl.dict.cc/?s={}'
c.url.searchengines['nl'] = 'https://de.pons.com/%C3%BCbersetzung/niederl%C3%A4ndisch-deutsch/{}'
c.url.searchengines['wl'] = 'https://woordenlijst.org/#/?q={}'
c.url.searchengines['dblp'] = 'https://dblp.org/search?q={}'

c.aliases['images'] = 'hint images tab'
c.aliases['tabopen'] = 'open -t'
c.aliases['mpv'] = 'spawn --userscript view_in_mpv'
c.aliases['data-href'] = 'spawn --userscript data-href'
c.aliases['user-agent'] = 'spawn --userscript user-agent-switcher'
c.aliases['pr0'] = 'spawn --userscript pr0gramm-up-downvotes'
c.aliases['reload-config'] = 'spawn --userscript reload-config'
c.aliases['r'] = 'config-source'


c.colors.completion.even.bg = '#242424'
c.colors.completion.odd.bg = c.colors.completion.even.bg
c.colors.completion.category.fg = '#FFE54F'
c.colors.completion.category.bg = '#121212'
c.colors.completion.category.border.top = c.colors.completion.category.bg
c.colors.completion.category.border.bottom = c.colors.completion.category.bg
c.colors.completion.item.selected.fg = '#9fbc00'
c.colors.completion.item.selected.bg = 'black'
c.colors.completion.item.selected.border.top = c.colors.completion.item.selected.bg
c.colors.completion.item.selected.border.bottom = c.colors.completion.item.selected.bg
c.colors.statusbar.normal.fg = '#9fbc00'
c.colors.statusbar.normal.bg = 'qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 black, stop:0.1 #010101, stop:1 #131313)'
c.colors.statusbar.insert.fg = 'white'
c.colors.statusbar.insert.bg = c.colors.statusbar.normal.bg
c.colors.statusbar.caret.fg = 'white'
c.colors.statusbar.caret.selection.fg = 'white'
c.colors.statusbar.progress.bg = '#D64937'
c.colors.statusbar.url.fg = 'white'
c.colors.statusbar.url.success.https.fg = '#FCFF9B'
c.colors.statusbar.url.error.fg = '#FF9999'
c.colors.statusbar.url.warn.fg = '#FF9999'
c.colors.statusbar.url.hover.fg = 'orange'
c.colors.tabs.odd.fg = '#989898'
c.colors.tabs.odd.bg = '#121212'
c.colors.tabs.even.fg = c.colors.tabs.odd.fg
c.colors.tabs.even.bg = c.colors.tabs.odd.bg
c.colors.tabs.pinned.even.fg = c.colors.tabs.odd.fg
c.colors.tabs.pinned.even.bg = c.colors.tabs.odd.bg
c.colors.tabs.pinned.odd.fg = c.colors.tabs.pinned.even.fg
c.colors.tabs.pinned.odd.bg = c.colors.tabs.pinned.even.bg
c.colors.tabs.selected.odd.bg = '#212121'
c.colors.tabs.selected.even.bg = c.colors.tabs.selected.odd.bg
c.colors.tabs.bar.bg = '#010101'
c.colors.tabs.indicator.start = '#888a85'
c.colors.tabs.indicator.stop = c.colors.tabs.indicator.start
c.colors.tabs.indicator.error = c.colors.tabs.indicator.start
c.colors.downloads.bar.bg = '#101010'
c.colors.downloads.start.fg = '#ffffff'
c.colors.downloads.start.bg = '#323232'
c.colors.downloads.stop.bg = '#323232'
c.colors.messages.error.bg = '#860309'
c.colors.messages.warning.fg = c.colors.statusbar.normal.fg
c.colors.prompts.bg = '#625B00'

#monospace = [ 'xos4 Terminus', 'Terminus', 'Monospace', "DejaVu Sans Mono", 'Monaco', "Bitstream Vera Sans Mono", "Andale Mono", "Courier New", 'Courier', "Liberation Mono", 'monospace', 'Fixed', 'Consolas', 'Terminal' ]
guifont = 'bold 8pt "Bitstream Vera Sans" bold'
# c.fonts.completion.category = guifont
# c.fonts.completion.entry = guifont
# c.fonts.tabs.selected = guifont
# c.fonts.tabs.unselected = guifont
# c.fonts.statusbar = 'bold 8pt "Bitstream Vera Sans"'
# c.fonts.downloads = '8pt bold "Bitstream Vera Sans"'
# c.fonts.hints = 'bold 12px "Bitstream Vera Sans"'
# c.fonts.web.family.fixed = 'Bitstream Vera Sans Mono'

import socket
if socket.gethostname() in ['x1g5']:
    c.zoom.default = '90%'

if 'cmd-set-text' in commands:
    cmd_set_text = 'cmd-set-text '  # newer versions
else:
    cmd_set_text = 'set-cmd-text '  # old qutebrowser

binds = {
    'O' : cmd_set_text + ':open {url}',
    't' : cmd_set_text + '-s :open -t ',
    'T' : cmd_set_text + ':open -t {url}',
    'gT' : 'tab-prev',
    'gt' : 'tab-next',
    '<' : 'tab-move -',
    '>' : 'tab-move +',
    '<home>' : 'scroll-perc 0',
    '0' : 'scroll-perc -x 0',
    '^' : 'scroll-perc -x 0',
    '$' : 'scroll-perc -x 100',
    '<end>' : 'scroll-perc',
    'yy' : 'yank ;; yank -s',
    'M' : cmd_set_text + '-s :quickmark-load',
    'm' : 'enter-mode set_mark',
    '\'' : 'enter-mode jump_mark',
    'zl' : 'spawn --userscript password_fill',
    'sd' : "spawn --userscript /bin/bash -c 'DOWNLOAD_DIR=~/downloads ~/.config/qutebrowser/userscripts/open_download'",
    '<Ctrl-Shift-j>' : "spawn --userscript dict-jp-lookup",
    ';v' : "hint links userscript view_in_mpv",
    'b' : cmd_set_text + "-s :tab-select",
}

for m in ['normal', 'insert']:
    config.bind('<Windows-\\>', 'spawn --userscript ~/dotfiles/menu/rofi-pass.sh',mode=m)

for k,v in binds.items():
    #config.bind(k, v, force=True)
    config.bind(k, v)


blocked_hosts = []
blocked_hosts_path = '~/.config/qutebrowser/block-hosts.txt'

try:
    with open(os.path.expanduser(blocked_hosts_path)) as fh:
        lines = [l.strip() for l in fh.readlines()]
        lines = [l for l in lines if not l.startswith('#')]
        blocked_hosts = lines
except Exception:
    pass



# attach variable to global namespace that is not evaluated again on :config-source
blocked_hosts_re = [re.compile(h) for h in blocked_hosts]

def get_blocked_hosts_re():
    global blocked_hosts_re
    return blocked_hosts_re

def redirect_certain_hosts(info: interceptor.Request):
    """keep me productive by redirecting certain hosts"""
    requested_host = info.request_url.host()
    if any([host.match(requested_host) for host in get_blocked_hosts_re()]):
        new_url = QUrl('https://gitlab.science.ru.nl/dashboard/projects/starred')
        message.info(f"Redirecting {requested_host} -> {new_url.url()}")
        # new_url = QUrl(info.request_url)
        # new_url.setHost('localhost')
        try:
            info.redirect(new_url)
        except Exception:
            pass

if not hasattr(qutebrowser.api, 'custom_interceptor'):
    def custom_interceptor(info: interceptor.Request):
        qutebrowser.api.custom_interceptor(info)
    # message.info("installing interceptor")
    interceptor.register(custom_interceptor)

qutebrowser.api.custom_interceptor = redirect_certain_hosts
