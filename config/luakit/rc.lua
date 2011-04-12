-----------------------------------------------------------------------
-- Luakit configuration file, more information at http://luakit.org/ --
-----------------------------------------------------------------------

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

function cmd_toggle_javascript(w, param)
        local value = not domain_props["all"]["enable-scripts"]
        if param then
            if (param == "true" or param == "on") then
                value = true
            end
            if (param == "false" or param == "off") then
                value = false
            end
        end
        domain_props["all"]["enable-scripts"] = value
        w:notify(string.format("Javascript is "..
                (value and "enabled" or "disabled")))
end

local key, buf, but = lousy.bind.key, lousy.bind.buf, lousy.bind.but

add_binds("normal", {
    lousy.bind.buf("^yy$", function (w)
        luakit.set_selection(w:get_current().uri, "clipboard")
        luakit.set_selection(w:get_current().uri)
        w:notify("Yanked: " .. w:get_current().uri)
    end)
}, true) -- true: overwrite already existing

add_binds("normal", {
    key({}, "b", function (w, m)
        w:enter_cmd(":bopen ")
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
            w:set_mode("cmdcomp")
        end
        if string.match(i.text, "^:tabopen ")
         or string.match(i.text, "^:open ")
         or string.match(i.text, "^:winopen ") then
            w:set_mode("bmarkcomp")
        end
    end),
}, true) -- true: overwrite already existing


local cmd = lousy.bind.cmd

add_cmds({cmd("togglejs", cmd_toggle_javascript )})
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
bookmarks.clear()
bookmarks.load(os.getenv("HOME").."/lbm")
--bookmarks.load()
--bookmarks.dump_html()

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

-- vim: et:sw=4:ts=8:sts=4:tw=80
