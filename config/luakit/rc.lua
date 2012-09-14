-----------------------------------------------------------------------
-- Luakit configuration file, more information at http://luakit.org/ --
-----------------------------------------------------------------------

if unique then
    unique.new("org.luakit")
    -- Check for a running luakit instance
    if unique.is_running() then
        if uris[1] then
            for _, uri in ipairs(uris) do
                unique.send_message("tabopen " .. uri)
            end
        else
            unique.send_message("winopen")
        end
        luakit.quit()
    end
end

-- Set standard C locale, otherwise `string.format("%f", 0.5)` could
-- return "0,5" (which was breaking link following for those locales).
--os.setlocale("C")

-- Load library of useful functions for luakit
require "lousy"

-- Small util functions to print output (info prints only when luakit.verbose is true)
function warn(...) io.stderr:write(string.format(...) .. "\n") end
function info(...) if luakit.verbose then io.stderr:write(string.format(...) .. "\n") end end

-- Small util function to print output only when luakit.verbose is true
function info(...) if luakit.verbose then print(string.format(...)) end end

-- Load users global config
-- ("$XDG_CONFIG_HOME/luakit/globals.lua" or "/etc/xdg/luakit/globals.lua")
require "globals"

dofile(os.getenv("HOME").."/.config/luakit/rc.local.lua")

-- Load users theme
-- ("$XDG_CONFIG_HOME/luakit/theme.lua" or "/etc/xdg/luakit/theme.lua")
lousy.theme.init(lousy.util.find_config("theme.lua"))
theme = assert(lousy.theme.get(), "failed to load theme")

-- Load users window class
-- ("$XDG_CONFIG_HOME/luakit/window.lua" or "/etc/xdg/luakit/window.lua")
require "window"

-- Load users mode configuration
-- ("$XDG_CONFIG_HOME/luakit/modes.lua" or "/etc/xdg/luakit/modes.lua")
require "modes"

-- Load users webview class
-- ("$XDG_CONFIG_HOME/luakit/webview.lua" or "/etc/xdg/luakit/webview.lua")
require "webview"

-- Load users keybindings
-- ("$XDG_CONFIG_HOME/luakit/binds.lua" or "/etc/xdg/luakit/binds.lua")
require "binds"

-- Add search mode & binds
require "search"

-- Add command history
require "cmdhist"

-- Save web history
require "history"

-- Add sqlite3 cookiejar
require "cookies"

-- own modules
require "plainmarks"

function cmd_toggle_plugins(w, param)
        local value = not domain_props["all"]["enable_plugins"]
        if param then
            if (param == "true" or param == "on") then
                value = true
            end
            if (param == "false" or param == "off") then
                value = false
            end
        end
        domain_props["all"].enable_plugins = value
        w:notify(string.format("Plugins are "..
                (value and "enabled" or "disabled")))
end


function cmd_toggle_javascript(w, param)
        local value = not domain_props["all"]["enable_scripts"]
        if param then
            if (param == "true" or param == "on") then
                value = true
            end
            if (param == "false" or param == "off") then
                value = false
            end
        end
        domain_props["all"].enable_scripts = value
        w:notify(string.format("Javascript is "..
                (value and "enabled" or "disabled")))
end

function cmd_set_useragent(w, param)
        local value = not domain_props["all"]["enable-scripts"]
        if useragents[param] then
            globals.useragent = useragents[param]
            w:notify(string.format("Useragent is "..param..": "..globals.useragent))
        else
            w:error(string.format("No useragent called \""..param.."\" "))
        end
end

local key, buf, but = lousy.bind.key, lousy.bind.buf, lousy.bind.but

add_binds("normal", {
    key({}, "b", function (w, m)
        w:enter_cmd(":bopen ")
    end)
}, true) -- true: overwrite already existing

add_binds("normal", {
    lousy.bind.buf("^sd$", function (w)
        w:set_mode("downloadlist")
    end)
}, true) -- true: overwrite already existing

add_binds("normal", {
    lousy.bind.buf("^JJ$", function (w)
        cmd_toggle_javascript(w, "")
    end)
}, true) -- true: overwrite already existing


add_binds("command", {
    -- Start completion
    key({}, "Tab", function (w)
        local i = w.ibar.input
        if not string.match(i.text, "%s") then
            -- Only complete commands, not args
            w:set_mode("completion")
        end
        if string.match(i.text, "^:tabopen ")
         or string.match(i.text, "^:open ")
         or string.match(i.text, "^:o ")
         or string.match(i.text, "^:t ")
         or string.match(i.text, "^:winopen ") then
            w:set_mode("bmarkcomp")
        end
    end),
}, true) -- true: overwrite already existing


local cmd = lousy.bind.cmd

add_cmds({cmd("togglejs", cmd_toggle_javascript )})
add_cmds({cmd("toggleplugins", cmd_toggle_plugins )})
add_cmds({cmd("useragent", cmd_set_useragent )})
--
--
-- Init scripts
require "follow"
--require "quickmarks"
require "proxy"
require "userscripts"
require "formfiller"
require "go_input"
require "follow_selected"
require "go_next_prev"
require "go_up"
require "session"
require "undoclose"
require "completion"
require "tabhistory"
require "taborder"

-- Add download support
require "downloads"
require "downloads_chrome"

-- Init bookmarks lib
require "bookmarks"
--bookmarks.clear()
--bookmarks.load(os.getenv("HOME").."/lbm")
--bookmarks.load()
--bookmarks.dump_html()

downloads.add_signal("download-location", function (uri, fname)
    for p, d in pairs({
        --["www%-m10.ma.tum.de"] = os.getenv("HOME") .. "/tum/gk",
        --["www%-m11.ma.tum.de"] = os.getenv("HOME") .. "/tum/algebra",
        --["www.sec.in.tum.de"] = os.getenv("HOME") .. "/tum/its",
        [ ".pdf$"  ] = os.getenv("HOME") .. "/downloads/",
    }) do
        if string.match(uri, p) then
            return string.format("%s/%s", d, fname)
        end
    end
end)


downloads.add_signal("open-file", function (f, m)
    local mime_types = {
        ["^text/"        ] = "gvim",
        ["^video/"       ] = "mplayer",
        ["/pdf$"         ] = "zathura",
    }
    local extensions = {
        ["mp3"           ] = "totem --enqueue",
        ["pdf"           ] = "zathura",
    }

    if m then
        for p,e in pairs(mime_types) do
            if string.match(m, p) then
                luakit.spawn(string.format('%s "%s"', e, f))
                return true
            end
        end
    end

    local _,_,ext = string.find(f, ".*%.([^.]*)")
    for p,e in pairs(extensions) do
        if string.match(ext, p) then
            luakit.spawn(string.format('%s "%s"', e, f))
            return true
        end
    end
end)



-----------------------------
-- End user script loading --
-----------------------------

-- Restore last saved session
local w = (session and session.restore())
if w then
    for i, uri in ipairs(uris) do
        w:new_tab(uri, i == 1)
    end
else
    -- Or open new window
    window.new(uris)
end
--
-------------------------------------------
-- Open URIs from other luakit instances --
-------------------------------------------

if unique then
    unique.add_signal("message", function (msg, screen)
        local cmd, arg = string.match(msg, "^(%S+)%s*(.*)")
        local w = lousy.util.table.values(window.bywidget)[1]
        if cmd == "tabopen" then
            w:new_tab(arg)
        elseif cmd == "winopen" then
            w = window.new((arg ~= "") and { arg } or {})
        end
        w.win:set_screen(screen)
    end)
end

-- vim: et:sw=4:ts=8:sts=4:tw=80
