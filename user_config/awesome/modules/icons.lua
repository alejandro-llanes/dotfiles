local gears = require("gears")

local config_dir = gears.filesystem.get_configuration_dir()
local icons_dir = config_dir .. "icons/"

class_icons = {
    ["Noi"]     = icons_dir .. "noi.png",
    ["Slack"]   = icons_dir .. "slack.png",
}
