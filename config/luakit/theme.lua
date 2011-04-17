--------------------------
-- Default luakit theme --
--------------------------

function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

theme_default = {}
-- Default settings
theme_default.font = "monospace normal 9"
theme_default.fg   = "#fff"
theme_default.bg   = "#000"

-- Genaral colours
theme_default.success_fg = "#0f0"
theme_default.loaded_fg  = "#33AADD"
theme_default.error_fg = "#FFF"
theme_default.error_bg = "#F00"

-- Warning colours
theme_default.warning_fg = "#F00"
theme_default.warning_bg = "#FFF"

-- Notification colours
theme_default.notif_fg = "#444"
theme_default.notif_bg = "#FFF"

-- Menu colours
theme_default.menu_fg                   = "#000"
theme_default.menu_bg                   = "#fff"
theme_default.menu_selected_fg          = "#000"
theme_default.menu_selected_bg          = "#FF0"
theme_default.menu_title_bg             = "#fff"
theme_default.menu_primary_title_fg     = "#f00"
theme_default.menu_secondary_title_fg   = "#666"

-- Proxy manager
theme_default.proxy_active_menu_fg      = '#000'
theme_default.proxy_active_menu_bg      = '#FFF'
theme_default.proxy_inactive_menu_fg    = '#888'
theme_default.proxy_inactive_menu_bg    = '#FFF'

-- Statusbar specific
theme_default.sbar_fg         = "#fff"
theme_default.sbar_bg         = "#000"

-- Downloadbar specific
theme_default.dbar_fg         = "#fff"
theme_default.dbar_bg         = "#000"
theme_default.dbar_error_fg   = "#F00"

-- Input bar specific
theme_default.ibar_fg           = "#000"
theme_default.ibar_bg           = "#fff"

-- Tab label
theme_default.tab_fg            = "#888"
theme_default.tab_bg            = "#222"
theme_default.tab_ntheme        = "#ddd"
theme_default.selected_fg       = "#fff"
theme_default.selected_bg       = "#000"
theme_default.selected_ntheme   = "#ddd"
theme_default.loading_fg        = "#33AADD"
theme_default.loading_bg        = "#000"

-- Trusted/untrusted ssl colours
theme_default.trust_fg          = "#0F0"
theme_default.notrust_fg        = "#F00"

follow_theme = {
    focus_bg     = "#ff0000";
    normal_bg    = "#FCE70D";
    opacity      = 0.3;
    border       = "1px solid #000000";
    tick_fg      = "#141414";
    tick_bg      = "#9FBC00";
    tick_border  = "1px solid #000000";
    tick_opacity = 0.8;
    tick_font    = "11px monospace bold";
    vert_offset  = 0;
    horiz_offset = -10;
}

theme_default.follow = follow_theme



------ greenterm ------
theme_greenterm = {}
-- Default settings
theme_greenterm.font = "bitstreams vera sans mono 8 bold"
--theme.font = "monospace 10"
theme_greenterm.fg   = "#9FBC00"
theme_greenterm.bg   = "#222222"

-- Error colours
theme_greenterm.error_fg = "#FFF"
theme_greenterm.error_bg = "#F00"

-- Notification colours
theme_greenterm.notif_fg = "#ef2929"
theme_greenterm.notif_bg = "#2e3436"

-- Statusbar specific
theme_greenterm.sbar_fg           = "#9FBC00"
theme_greenterm.sbar_bg           = "#222222"
theme_greenterm.loaded_sbar_fg    = "#FE4365"

-- Input bar specific
theme_greenterm.ibar_fg           = "#dddddd"
theme_greenterm.ibar_bg           = "#222222"

-- Tab label
theme_greenterm.tab_fg            = "#DAFF30"
theme_greenterm.tab_bg            = "#222222"
theme_greenterm.selected_fg       = "#ED4511"
theme_greenterm.selected_bg       = "#171717"

-- Trusted/untrusted ssl colours
theme_greenterm.trust_fg          = "#0F0"
theme_greenterm.notrust_fg        = "#F00"

------- theme with dark input bar -----
theme_tw = table.copy(theme_default)
theme_tw.font = "bitstreams vera sans mono 8 bold"
theme_tw.menu_fg                   = "#efefef"
theme_tw.menu_bg                   = "#222222"
theme_tw.menu_selected_fg          = "#222222"
theme_tw.menu_selected_bg          = "#9fbc00"
theme_tw.menu_title_bg             = "#141414"
theme_tw.menu_primary_title_fg     = "#E3BE09"
theme_tw.menu_secondary_title_fg   = "#D6156C"
theme_tw.loaded_fg  = "#9fbc00"


-- Statusbar specific
theme_tw.sbar_fg           = "#dddddd"
theme_tw.sbar_bg           = "#000000"
theme_tw.loaded_sbar_fg    = "#FE4365"

-- Input bar specific
theme_tw.ibar_fg           = "#9FBC00"
theme_tw.ibar_bg           = "#141414"


------ pwmt ------
theme_pwmt = table.copy(theme_tw)
-- Default settings
--theme_pwmt.font = "bitstreams vera sans mono 9 bold"
theme_pwmt.font = "Monospace bold 9"
--theme.font = "monospace 10"
theme_pwmt.fg   = "#9FBC00"
theme_pwmt.bg   = "#222222"

-- Error colours
theme_pwmt.error_fg = "#FFF"
theme_pwmt.error_bg = "#F00"

-- Notification colours
theme_pwmt.notif_fg = "#ef2929"
theme_pwmt.notif_bg = "#2e3436"

-- Tab label
theme_pwmt.tab_fg            = "#efefef"
theme_pwmt.tab_bg            = "#232323"
theme_pwmt.selected_fg       = "#232323"
theme_pwmt.selected_bg       = "#9FBC00"

-- Trusted/untrusted ssl colours
theme_pwmt.trust_fg          = "#0F0"
theme_pwmt.notrust_fg        = "#F00"
theme_pwmt.loading_fg        = "#ff1212"
theme_pwmt.loading_bg        = "#ff0000"





------ blue ------
theme_blue = table.copy(theme_tw)
--"dmenu -i -r -c -rs -nb #efefef -nf #272727 -sb #adc0ea -sf #202020 -fn -*-profont-*-*-*-*-12-*-*-*-*-*-*-* -ni"
theme_blue.ibar_fg = "#adc0ea"
theme_blue.selected_fg = "#272727"
theme_blue.selected_bg = "#efefef"
theme_blue.menu_selected_fg = "#adc0ea"
theme_blue.menu_selected_bg = "#090909"
-- Statusbar specific
theme_blue.sbar_fg         = "#efefef"
theme_blue.sbar_bg         = "#272727"

function evaluate_cmd(cmd)
    pipe = io.popen(cmd, "r")
    output = pipe:read("*all")
    pipe:close()
    return output
end

--print ("hostname = "..evaluate_cmd("hostname"))
hostname = evaluate_cmd("hostname")
--if hostname == "towi04\n" or string.find(hostname, "^faui.*\n") then
if false and string.find(hostname, "^faui.*\n") then
    theme = theme_blue
else
    theme = theme_pwmt
end

return theme
-- vim: et:sw=4:ts=8:sts=4:tw=80
