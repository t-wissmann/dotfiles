
-- add the following to your rc.lua
-- dofile(os.getenv("HOME").."/.config/luakit/rc.local.lua")
globals.term = "roxterm"
globals.term = "urxvt"

globals.homepage = "about:blank"
globals.useragent = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6"
--globals.useragent = "Mozilla/5.0 (X11; Linux x86_64; rv:2.0) Gecko/20110325 Firefox/4.0"

--search_engines.duk = "http://duckduckgo.com/html/?q=%s"
search_engines.d = "http://duckduckgo.com/html/?q=%s"
--search_engines.google = "http://www.google.com/search?hl=de&q=%s"
search_engines["g"] = "http://www.google.com/search?hl=de&q=%s"
search_engines.gimg = "http://www.google.com/images?hl=de&source=imghp&q=%s"
search_engines.lmgtfy = "http://lmgtfy.com/?hl=de&q=%s"

search_engines.wiki = "http://de.wikipedia.org/wiki/Special:Search?search=%s"
search_engines["wiki-en"] = "http://en.wikipedia.org/wiki/Special:Search?search=%s"
search_engines["tab"] = "http://www.guitaretab.com/fetch/?type=tab&query=%s"
search_engines["latein"] = "http://www.frag-caesar.de/lateinwoerterbuch/%s-uebersetzung.html"

search_engines.aur = "http://aur.archlinux.org/packages.php?K=%s&do_Search=Go"
search_engines.arch      = "https://wiki.archlinux.de/index.php?search=%s&go=Seite"
search_engines["arch-en"] = "http://wiki.archlinux.org/index.php/%s"
-- requires javascript...
--search_engines["selfhtml"] = "http://de.selfhtml.org/navigation/suche/index.htm?Suchanfrage=%s"

search_engines.leo = "http://dict.leo.org/ende?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=&search=%s"
search_engines.youtube = "http://www.youtube.com/results?search_query=%s"
search_engines.gpg = "http://gpg-keyserver.de/pks/lookup?search=0x%s&op=vindex"
search_engines["27c3-phone"] = "http://www.eventphone.de/guru2/phonebook?event=27C3&s=%s&installedonly=0&submit=Search"
search_engines["27c3"] = "https://events.ccc.de/congress/2010/wiki/Special:Search?search=%s"
search_engines["hoogle"] = "http://haskell.org/hoogle/?hoogle=%s"
search_engines.default = search_engines.d

-- Per-domain webview properties
domain_props = {
    ["all"] = {
        ["enable-scripts"]          = false,
        ["enable-plugins"]          = false,
        ["enable-private-browsing"] = false,
        ["user-stylesheet-uri"]     = "file://"..os.getenv("HOME").."/.config/luakit/style.css",
        --["accept-policy"]           = cookie_policy.no_third_party,
    },
    ["youtube.com"] = {
        ["enable-scripts"] = true,
        ["enable-plugins"] = true,
    },
    ["www.heise.de"] = { ["enable-scripts"] = true, ["enable-plugins"] = true, },
--    ["presale.events.ccc.de"] = { ["enable-scripts"] = true, ["enable-plugins"] = true, },
    ["www.hr-fernsehen.de"] = { ["enable-scripts"] = true, ["enable-plugins"] = true, },
    ["powerc109.galaxy-gmbh-service.de"] = { ["enable-scripts"] = true, },
    ["willkommen.sparkasse-erlangen.de"] = { ["enable-scripts"] = true, },
    ["realschule-graefenberg.de"] = { ["enable-scripts"] = true, },
    ["www.wolfram-alpha.com"] = { ["enable-scripts"] = true, },
    ["www.spin.de"] = { ["enable-scripts"] = true, },
    ["spin.de"] = { ["enable-scripts"] = true, },
    ["energy.spin.de"] = { ["enable-scripts"] = true, },
    ["www.sso.uni-erlangen.de"] = { ["enable-scripts"] = true, },
    ["www.studon.uni-erlangen.de"] = { ["enable-scripts"] = true, },
    ["fits.online-reseller.at"] = { ["enable-scripts"] = true, },
    ["listen.grooveshark.com"] = { ["enable-scripts"] = true, ["enable-plugins"] = true, },
    ["panopticlick.eff.org"] = { ["enable-scripts"] = true, },
    ["narf-archive.com"] = { ["enable-scripts"] = true, },
}



