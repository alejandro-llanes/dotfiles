local awful = require("awful")

local function update_screens(card, wallpaper_image_path, screen_0_panel, screens_manager)
	local xrandr_output = run_command_sync("xrandr")
	local primary_output = xrandr_output:match("([a-zA-Z0-9-]+) connected primary")
	if primary_output == nil then
		primary_output = xrandr_output:match("([a-zA-Z0-9-]+) connected")
	end
	local primary_output_rect =
		xrandr_output:match(primary_output:gsub("-", "[-]") .. " connected[a-z ]* ([0-9x+]+) [(]")

	local is_secondary_output_in_use = false
	local is_screen_duplicated = false

	for _, secondary_output_name in ipairs({ "HDMI", "DisplayPort", "DVI", "DP" }) do
		is_secondary_output_in_use = is_secondary_output_in_use
			or string.match(xrandr_output, secondary_output_name .. "[0-9-]+ connected [^(]") ~= nil
		local unused_secondary_output = xrandr_output:match("(" .. secondary_output_name .. "[0-9-]+) connected [(]")
		local used_secondary_output = xrandr_output:match("(" .. secondary_output_name .. "[0-9-]+) connected [^(]")
		local used_secondary_output_rect =
			xrandr_output:match(secondary_output_name .. "[0-9-]+ connected[a-z ]* ([0-9x+]+) [(]")
		local disconnected_secondary_output_rect =
			xrandr_output:match(secondary_output_name .. "[0-9-]+ disconnected[a-z ]* ([0-9x+]+) [(]")
		local is_secondary_output_disconnected = unused_secondary_output == nil and used_secondary_output == nil
		is_screen_duplicated = is_screen_duplicated or primary_output_rect == used_secondary_output_rect

		if (not is_secondary_output_in_use and unused_secondary_output) or is_screen_duplicated then
			local secondary_output = is_screen_duplicated and used_secondary_output or unused_secondary_output
			break
		else
			if is_secondary_output_disconnected and disconnected_secondary_output_rect then
				run_command_sync("xrandr --auto")
				break
			end
		end
	end

	if card == nil then
		local screen0 = Screen()
		screen0.wallpaper = wallpaper_image_path
		screen0.panels = { screen_0_panel }

		if is_secondary_output_in_use and not is_screen_duplicated then
			local screen1 = Screen()
			screen1.wallpaper = wallpaper_image_path
			screen1.panels = { screen_0_panel }

			screens_manager.set_screens({ screen0, screen1 })
		else
			screens_manager.set_screens({ screen0 })
		end

		screens_manager.apply_screens()
	end
end

local M = {}

M.setup = function(vars, panels, screens_manager)
	update_screens(nil, vars.wallpaper_image_path, panels.screen_0_panel, screens_manager)

	screen.connect_signal("added", function()
		if screen.count() > screens_manager.get_screen_count() then
			local newScreen = Screen()
			newScreen.wallpaper = vars.wallpaper_image_path
			newScreen.panels = { panels.screen_0_panel }

			screens_manager.add_screen(newScreen)
		end
		screens_manager.apply_screen(screens_manager.get_screen_count())
	end)
end

return M
