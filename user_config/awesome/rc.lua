require("utils")
require("helper")
require("modules/icons")
require("modules/create_class")
require("modules/modal_prompt")
require("modules/screen")
require("modules/tag")
require("modules/panel")
require("modules/widgets/cpu_widget")
require("modules/widgets/memory_widget")
require("modules/widgets/network_widget")
require("modules/widgets/bluetooth_widget")
require("modules/widgets/brightness_widget")
require("modules/widgets/battery_widget")
require("modules/widgets/calendar_widget")
require("modules/widgets/clock_widget")
require("modules/widgets/menu_widget")
require("modules/widgets/keyboard_layout_widget")
require("modules/widgets/volume_widget")
require("modules/widgets/microphone_widget")
require("modules/widgets/launch_widget")
require("modules/widgets/media_widget")
require("modules/widgets/clipboard_widget")

require("awful.autofocus")

local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

require("modules.error_handling")

local screens_manager = require("modules/screens_manager")

local config_path = gears.filesystem.get_configuration_dir()
beautiful.init(config_path .. "/themes/relz/theme.lua")

local vars = require("config.variables")
local widgets = require("config.widgets")
local panels = require("config.panels")
local screens = require("config.screens")
local keys = require("config.keys")
local rules = require("config.rules")
local signals = require("config.signals")
local init = require("config.initialization")
local autostart = require("config.autostart")

root.keys(keys.global_keys)

rules.setup(widgets)
awful.rules.rules = rules.client_rules
rules.setup_titlebars()

signals.setup_icon_signal()
signals.setup_urgent_signal()
signals.setup_focus_signal()

screens.setup(vars, panels, screens_manager)

init.run(vars, widgets)
autostart.run(vars)
