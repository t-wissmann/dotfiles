

-- add the following to your rc.lua
-- dofile(os.getenv("HOME").."/.config/luakit/rc.local.lua")
globals.term = "roxterm"
globals.term = "urxvt"

globals.homepage = "about:blank"

useragents = {
    ["ff4"] = "Mozilla/5.0 (X11; Linux x86_64; rv:2.0) Gecko/20110325 Firefox/4.0",
    ["ff2"] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6",
}

globals.useragent = useragents["ff2"]

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
search_engines["dict"] = "http://www.dict.cc/?s=%s"


search_engines.aur = "http://aur.archlinux.org/packages.php?K=%s&do_Search=Go"
search_engines.arch      = "https://wiki.archlinux.de/index.php?search=%s&go=Seite"
search_engines["arch-en"] = "http://wiki.archlinux.org/index.php/%s"
-- requires javascript...
--search_engines["selfhtml"] = "http://de.selfhtml.org/navigation/suche/index.htm?Suchanfrage=%s"
--
search_engines["tineye"] = "http://www.tineye.com/parse?url=%s"

search_engines.leo = "http://dict.leo.org/ende?lp=ende&lang=de&searchLoc=0&cmpType=relaxed&sectHdr=on&spellToler=&search=%s"
search_engines.youtube = "http://www.youtube.com/results?search_query=%s"
search_engines.gpg = "http://gpg-keyserver.de/pks/lookup?search=0x%s&op=vindex"
search_engines["27c3-phone"] = "http://www.eventphone.de/guru2/phonebook?event=27C3&s=%s&installedonly=0&submit=Search"
search_engines["27c3"] = "https://events.ccc.de/congress/2010/wiki/Special:Search?search=%s"
search_engines["hoogle"] = "http://haskell.org/hoogle/?hoogle=%s"
search_engines.default = search_engines.g

-- Per-domain webview properties
domain_props = {
    ["all"] = {
        enable_scripts          = false,
        enable_plugins          = false,
        enable_private_browsing = false,
        user_stylesheet_uri     = "file://"..os.getenv("HOME").."/.config/luakit/style.css",
        --accept_policy           = cookie_policy.no_third_party,
    },
    ["youtube.com"] = {
        enable_scripts = true,
        enable_plugins = true,
    },
    ["myvideo.de"] = {
        enable_scripts = true,
        enable_plugins = true,
    },
    ["www.heise.de"] = { enable_scripts = true, enable_plugins = true, },
--    ["presale.events.ccc.de"] = { enable_scripts = true, enable_plugins = true, },
    ["www.hr-fernsehen.de"] = { enable_scripts = true, enable_plugins = true, },
    ["powerc109.galaxy-gmbh-service.de"] = { enable_scripts = true, },
    ["willkommen.sparkasse-erlangen.de"] = { enable_scripts = true, },
    ["realschule-graefenberg.de"] = { enable_scripts = true, },
    ["www.wolfram-alpha.com"] = { enable_scripts = true, },
    ["www.spin.de"] = { enable_scripts = true, },
    ["spin.de"] = { enable_scripts = true, },
    ["energy.spin.de"] = { enable_scripts = true, },
    ["www.sso.uni-erlangen.de"] = { enable_scripts = true, },
    ["www.studon.uni-erlangen.de"] = { enable_scripts = true, },
    ["fits.online-reseller.at"] = { enable_scripts = true, },
    ["listen.grooveshark.com"] = { enable_scripts = true, enable_plugins = true, },
    ["panopticlick.eff.org"] = { enable_scripts = true, },
    ["narf-archive.com"] = { enable_scripts = true, },
}



