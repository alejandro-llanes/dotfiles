local gears = require("gears")
local naughty = require("naughty")
local cairo = require("lgi").cairo
local awful = require("awful")

local M = {}

M.setup_icon_signal = function()
	client.connect_signal("manage", function(c)
		if c and c.valid and not c.icon and class_icons[c.class] then
			naughty.notify({ text = c.class .. " does not have valid icon." })
			local sf = gears.surface(class_icons[c.class])
			local img = cairo.ImageSurface.create(cairo.Format.ARGB32, sf:get_width(), sf:get_height())
			local cr = cairo.Context(img)
			cr:set_source_surface(sf, 0, 0)
			cr:paint()
			c.icon = img and img._native or nil
		end
	end)
end

M.setup_urgent_signal = function()
	client.connect_signal("property::urgent", function(c)
		if c.urgent then
			local t = c.first_tag
			if t then
				t:view_only()
			end
		end
	end)
end

M.setup_focus_signal = function()
	client.connect_signal("manage", function(c, startup)
		c:connect_signal("mouse::enter", function(c)
			if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
				client.focus = c
			end
		end)

		if not startup and not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end)
end

return M
