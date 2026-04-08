local awful = require("awful")
local vars = require("config.variables")
local widgets = require("config.widgets")

local task_left_button_press_action = function(c)
	if not is_client_in_tag(c, awful.tag.selected()) then
		return
	end

	if c == client.focus then
		c.minimized = true
	else
		c:emit_signal("request::activate", "tasklist", { raise = true })
	end
end

local screen_0_panel = Panel()
screen_0_panel.position = "top"
screen_0_panel.floating = true
screen_0_panel.margin = dpi(4)

if vars.current_os == "Linux" then
	screen_0_panel.thickness = 32
	screen_0_panel.opacity = 0.9
end
screen_0_panel.tags.list = {
	Tag("1", awful.layout.suit.spiral),
}
screen_0_panel.tags.key_bindings =
	awful.util.table.join(awful.button({}, 1, awful.tag.viewonly), awful.button({ "Mod4" }, 1, awful.client.movetotag))
screen_0_panel.tasks.key_bindings = awful.util.table.join(awful.button({}, 1, task_left_button_press_action))
if vars.current_os == "Linux" then
	screen_0_panel.widgets = {
		widgets.keyboard_layout_widget,
		widgets.cpu_widget,
		widgets.memory_widget,
		widgets.microphone_widget,
		widgets.brightness_widget,
		widgets.network_widget,
		widgets.bluetooth_widget,
		widgets.volume_widget,
		widgets.media_widget,
		widgets.clipboard_widget,
		{
			widgets.calendar_widget,
			widgets.clock_widget,
		},
		widgets.menu_widget,
		wibox.widget.systray(),
	}
end
if vars.current_os == "FreeBSD" then
	screen_0_panel.widgets = {
		widgets.cpu_widget,
		widgets.memory_widget,
		widgets.network_widget,
		widgets.bluetooth_widget,
		widgets.volume_widget,
		widgets.microphone_widget,
		widgets.brightness_widget,
		widgets.battery_widget,
		widgets.keyboard_layout_widget,
		{
			widgets.calendar_widget,
			widgets.clock_widget,
		},
		widgets.menu_widget,
	}
end
screen_0_panel.launcher = widgets.launch_widget

return {
	screen_0_panel = screen_0_panel,
}
