local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local keys = require("config.keys")

local M = {}

local hide_dropdowns = nil

local client_buttons = awful.util.table.join(
	awful.button({}, 1, function() hide_dropdowns() end),
	awful.button({}, 2, function() hide_dropdowns() end),
	awful.button({}, 3, function() hide_dropdowns() end),
	awful.button({ "Mod4" }, 1, move_client),
	awful.button({ "Mod4" }, 3, resize_client)
)

M.setup = function(widgets)
	hide_dropdowns = function()
		widgets.menu_widget.hide_dropdown()
		widgets.volume_widget.hide_dropdown()
		widgets.brightness_widget.hide_dropdown()
	end

	local hotkeys_popup = require("awful.hotkeys_popup.widget")
	hotkeys_popup.add_hotkeys({
		["Client"] = {
			{
				modifiers = { "Mod4" },
				keys = {
					LMB = "Move focused client",
					RMB = "Resize focused client",
				},
			},
		},
	})
	hotkeys_popup.add_group_rules("Client")
end

M.client_rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			keys = keys.client_keys,
			buttons = client_buttons,
			titlebars_enabled = false,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},
	{
		rule_any = {},
		except_any = { type = { "normal" }, class = { "Emacs" } },
		properties = {
			skip_taskbar = true,
			focusable = false,
		},
		callback = function(c)
			awful.placement.centered(c.focus)
		end,
	},
	{
		rule = { class = "Alacritty" },
		properties = {
			tag = "1",
			switchtotag = true,
			focus = true,
		},
	},
	{
		rule = { class = "org.remmina.Remmina" },
		properties = {
			minimized = true,
			skip_taskbar = true,
		},
	},
	{
		rule_any = { type = { "normal" }, class = { "Emacs" } },
		except_any = { class = { "Alacritty" } },
		properties = {
			floating = false,
			switchtotag = true,
			focus = true,
			new_tag = {
				volatile = true,
				layout = awful.layout.suit.spiral,
			},
		},
	},
}

M.setup_titlebars = function()
	client.connect_signal("request::titlebars", function(c)
		local buttons = awful.util.table.join(
			awful.button({}, 1, function()
				move_client(c)
			end),
			awful.button({}, 3, function()
				resize_client(c)
			end)
		)

		awful.titlebar(c, { size = 24 }):setup({
			{
				wibox.container.margin(awful.titlebar.widget.closebutton(c), 0, 0, 2, 2),
				wibox.container.margin(awful.titlebar.widget.maximizedbutton(c), 0, 0, 2, 2),
				wibox.container.margin(awful.titlebar.widget.minimizebutton(c), 0, 0, 2, 2),
				layout = wibox.layout.fixed.horizontal,
			},
			{
				{
					align = "center",
					widget = awful.titlebar.widget.titlewidget(c),
				},
				buttons = buttons,
				layout = wibox.layout.flex.horizontal,
			},
			{
				buttons = buttons,
				layout = wibox.layout.fixed.horizontal(),
			},
			layout = wibox.layout.align.horizontal,
		})
	end)
end

return M
