local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local theme = {}

-- borders
theme.border_width = dpi(1)
theme.useless_gap   = dpi(4)
theme.border_width  = dpi(4)
theme.border_normal = "#00332e"
theme.border_focus  = "#00C8AE"
theme.border_marked = "#7AFFF0"
-- bar
theme.wibar_opacity = 0.8

-- tags
theme.taglist_fg_focus = "#000000"
theme.taglist_bg_focus = "#ffffff"

--theme.font = "Source Code Pro 9"
theme.font = "Iosevka Nerd Font 10"

--theme.wallpaper = themes_path .. "9matter/9matter.jpg"
theme.wallpaper = gfs.get_configuration_dir() .. "themes/9matter/9matter.jpg"

theme.icon_theme = nil

return theme
