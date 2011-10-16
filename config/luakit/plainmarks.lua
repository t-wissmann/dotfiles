

-- Prepare local environment
local os = os
local io = io
local assert = assert
local string = string
local ipairs = ipairs
local pairs = pairs
local tostring = tostring
local type = type
local table = table
local window = window
local lousy = require "lousy"
local capi = { luakit = luakit }

local new_mode, add_binds, add_cmds, menu_binds = new_mode, add_binds, add_cmds, menu_binds

local cmd = lousy.bind.cmd


module("plainmarks")
local bmarkfile = os.getenv("HOME").."/.config/bookmarks"

function build_completion_menu(w, needle)
    local rows = {{ "Bookmark", "URI", title = true }}
    local pipe = io.popen("grep -iE \""..needle.."\" \""..bmarkfile.."\"", "r")
    while true do
        local line = pipe:read("*line")
        if not line then
            break
        end
        local uri = string.match(line, "^[^ ]*");
        local title = string.match(line, " .*$")
        title = string.sub(title, 2)
        table.insert(rows, { title, uri, uri = uri })
    end
    pipe:close()
    w.menu:build(rows)
end

new_mode("bmarklist", {
    enter = function (w)
        -- needle is all in inputbar except first word
        local needle = string.match(w.ibar.input.text, " .*$")
        needle = string.sub(needle, 2) -- remove first space
        build_completion_menu(w, needle);
        w:notify("Use j/k to move, w winopen, b to retry :bopen", false)
    end,

    leave = function (w)
        w.menu:hide()
    end,
})
new_mode("bmarkcomp", {
    enter = function (w)
        -- needle is all in inputbar except first word
        local needle = string.match(w.ibar.input.text, " .*$")
        -- Get completion text
        w.comp_state = {}
        w.comp_state.orig = string.sub(w.ibar.input.text, 2)
        w.comp_state.cmd = string.match(w.ibar.input.text, "^[^ ]*")
        w.comp_state.orig_pos = w.ibar.input.position
        local s = w.comp_state;
        needle = string.sub(needle, 2) -- remove first space
        build_completion_menu(w, needle);
        w.menu:add_signal("changed", function(m, row)
            local pos
            if row then
                s.text = s.cmd .." " .. row.uri
                pos = #(s.text) + 1
            else
                s.text = ":" .. s.orig
                pos = s.orig_pos
            end
            -- Update input bar
            w.ibar.input.text = s.text
            w.ibar.input.position = pos
        end)
        -- Set initial position
        w.menu:move_down()
    end,
    leave = function (w)
        w.menu:hide()
        -- Remove all changed signal callbacks
        w.menu:remove_signals("changed")
    end,
    activate = function (w, text)
        -- when an item is selected
        w:enter_cmd(text)
    end,
})



add_cmds({cmd("bmark", function (w, param)
        local uri = w.view.uri
        if not param or param == "" then
            w:error(string.format("No bookmark name given"))
        else
            os.execute("echo \""..uri.." "..param.."\" >> "..bmarkfile);
        end
        --w:error(string.format("You entered: %q", w:get_current().uri))
    end)})

add_cmds({cmd("bopen", function (w, param)
        w:set_mode("bmarklist")
    end)})

local key = lousy.bind.key
add_binds("bmarklist", lousy.util.table.join({
    -- Open quickmark in new window
    key({}, "w", function (w)
        local row = w.menu:get()
        if row and row.uri then
            window.new({ row.uri } or {})
        end
    end),
    key({}, "t", function (w)
        local row = w.menu:get()
        if row and row.uri then
            w:new_tab(w:search_open(row.uri), false)
        end
    end),
    key({}, "Return", function (w)
        local row = w.menu:get()
        if row and row.uri then
            w:navigate(w:search_open(row.uri), false)
        end
    end),
    key({}, "b", function (w)
        w:set_mode()
        w:enter_cmd(":bopen ")
    end),

    -- Exit menu
    key({}, "q", function (w) w:set_mode() end),

}, menu_binds))


-- Exit completion
local function exitcomp(w)
    w:enter_cmd(":" .. w.comp_state.orig)
    w.ibar.input.position = w.comp_state.orig_pos
end

-- Command completion binds
add_binds("bmarkcomp", {
    key({},          "Tab",     function (w) w.menu:move_down() end),
    key({"Shift"},   "Tab",     function (w) w.menu:move_up()   end),
    key({},          "Escape",  exitcomp),
    key({"Control"}, "[",       exitcomp),
})


-- vim: et:sw=4:ts=8:sts=4:tw=80
