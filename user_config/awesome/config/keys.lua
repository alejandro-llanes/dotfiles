local awful = require("awful")
local gears = require("gears")
local vicious = require("vicious")
local vars = require("config.variables")
local widgets = require("config.widgets")

local set_brightness = function(step_percent, increase)
	set_system_brightness(step_percent, increase, function(new_value_percent)
		widgets.brightness_widget.update(new_value_percent)
	end)
end

local mute = function()
	local command = "amixer -D pulse set Master 1+ toggle"
	awful.spawn.easy_async(command, function()
		vicious.force({ widgets.volume_widget.icon })
	end)
end

local set_volume = function(step, increase)
	set_sink_volume(step, increase, function()
		vicious.force({ widgets.volume_widget.icon })
	end)
end

local swap_clients_between_tags = function(direction)
	local scr = awful.screen.focused()
	local tags = scr.tags
	local current_tag = scr.selected_tag
	if not current_tag then
		return
	end

	local index = current_tag.index
	local next_index = index + direction

	if next_index < 1 or next_index > #tags then
		return
	end

	local target_tag = tags[next_index]
	local current_clients = current_tag:clients()
	local target_clients = target_tag:clients()

	local was_current_volatile = current_tag.volatile
	local was_target_volatile = target_tag.volatile
	current_tag.volatile = false
	target_tag.volatile = false

	for _, c in ipairs(current_clients) do
		c:move_to_tag(target_tag)
	end
	for _, c in ipairs(target_clients) do
		c:move_to_tag(current_tag)
	end

	current_tag.volatile = was_current_volatile
	target_tag.volatile = was_target_volatile

	target_tag:view_only()
end

local toggle_panel = function()
	local panel_ref = awful.screen.focused().panel
	if panel_ref ~= nil and panel_ref.visible ~= nil then
		panel_ref.visible = not panel_ref.visible
	end
end

local global_keys = gears.table.join(
	awful.key({ "Mod4" }, "/", show_help, { description = "Show hotkeys", group = "Awesome" }),

	awful.key({ "Mod4" }, ".", show_help),

	awful.key({ "Mod4", "Mod1" }, "t", function()
		naughty.notify({ title = "test os", text = tostring(vars.current_os) })
	end),

	awful.key({ "Mod4" }, "x", function()
		awful.spawn("rofi -show drun -columns 3")
	end, { description = "Launcher", group = "launcher" }),

	awful.key({}, "Print", function()
			awful.spawn.with_shell("maim ~/Pictures/screenshoot_$(date +'%Y-%m-%d_%H-%M-%s').png")
	end, { description = "Screenshoot", group = "Screen" }),

	awful.key({ "Shift" }, "Print", function()
		awful.spawn.with_shell("maim -s --hidecursor ~/Pictures/screenshoot_$(date +'%Y-%m-%d_%H-%M-%s').png")
	end, { description = "Screenshot select area", group = "Screen" }),

	awful.key({ "Mod4", "Shift" }, "e", function()
		repl_modal()
	end, { description = "Modal Code Eval", group = "Awesome" }),

	awful.key({ "Mod4", "Shift" }, "b", function()
		toggle_panel()
	end, { description = "Toggle Panel", group = "Awesome" }),

	awful.key({ "Mod4" }, "Tab", function()
		change_focused_client(1)
	end, { description = "Change focused client to next", group = "Client" }),

	awful.key({ "Mod4", "Shift" }, "Tab", function()
		change_focused_client(-1)
	end, { description = "Change focused client to previous", group = "Client" }),

	awful.key({ "Control", "Mod1" }, "Left", function()
		awful.tag.viewidx(-1)
	end, { description = "Move to left tag", group = "Client" }),

	awful.key({ "Control", "Mod1" }, "Right", function()
		awful.tag.viewidx(1)
	end, { description = "Move to right tag.", group = "Client" }),

	awful.key({ "Mod4", "Mod1" }, "Left", function()
		awful.client.focus.bydirection("left")
	end, { description = "focus window to the left", group = "client" }),

	awful.key({ "Mod4", "Mod1" }, "Right", function()
		awful.client.focus.bydirection("right")
	end, { description = "focus window to the right", group = "client" }),

	awful.key({ "Mod4", "Mod1" }, "Up", function()
		awful.client.focus.bydirection("up")
	end, { description = "focus window above", group = "client" }),

	awful.key({ "Mod4", "Mod1" }, "Down", function()
		awful.client.focus.bydirection("down")
	end, { description = "focus window below", group = "client" }),

	awful.key({ "Mod4", "Control" }, "r", awesome.restart, { description = "Restart awesome", group = "Awesome" }),

	awful.key({ "Mod4", "Shift" }, "q", awesome.quit, { description = "Quit awesome", group = "Awesome" }),

	awful.key({ "Control", "Mod1" }, "l", function()
		awful.spawn(vars.session_lock_command)
	end, { description = "Lock the session", group = "Session" }),

	awful.key({ "Mod4" }, "Return", function()
		awful.spawn(vars.terminal)
	end, { description = "Execute default terminal (" .. vars.terminal .. ")", group = "Application" }),

	awful.key({}, "XF86MonBrightnessUp", function()
		set_brightness(5, true)
	end, { description = "Increase brightness by 5", group = "Brightness" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		set_brightness(5, false)
	end, { description = "Decrease brightness by 5", group = "Brightness" }),

	awful.key({ "Control" }, "XF86MonBrightnessUp", function()
		set_brightness(10, true)
	end, { description = "Increase brightness by 10", group = "Brightness" }),
	awful.key({ "Control" }, "XF86MonBrightnessDown", function()
		set_brightness(10, false)
	end, { description = "Decrease brightness by 10", group = "Brightness" }),

	awful.key({}, "XF86AudioMute", function()
		mute()
	end, { description = "Toggle sound volume", group = "Volume" }),

	awful.key({}, "XF86AudioRaiseVolume", function()
		set_volume(5, true)
	end, { description = "Raise volume by 5", group = "Volume" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		set_volume(5, false)
	end, { description = "Lower volume by 5", group = "Volume" }),

	awful.key({ "Control" }, "XF86AudioRaiseVolume", function()
		set_volume(10, true)
	end, { description = "Raise volume by 10", group = "Volume" }),
	awful.key({ "Control" }, "XF86AudioLowerVolume", function()
		set_volume(10, false)
	end, { description = "Lower volume by 10", group = "Volume" }),

	awful.key({}, "XF86AudioPrev", function()
		audio_previous()
	end, { description = "Previous audio", group = "Audio" }),
	awful.key({}, "XF86AudioPlay", function()
		audio_toggle_play_pause()
	end, { description = "Play/Pause audio", group = "Audio" }),
	awful.key({}, "XF86AudioNext", function()
		audio_next()
	end, { description = "Next audio", group = "Audio" }),
	awful.key({}, "XF86AudioStop", function()
		audio_stop()
	end, { description = "Stop audio", group = "Audio" }),

	awful.key({ "Mod4" }, "k", function()
		awful.spawn("xkill")
	end, { description = "Execute XKill", group = "Application" }),

	awful.key({ "Mod4" }, "\\", function()
		awful.spawn("arandr")
	end, { description = "Execute ARandr", group = "Application" }),

	awful.key(
		{ "Mod4" },
		"d",
		toogle_minimize_restore_clients,
		{ description = "Toggle minimize restore clients", group = "Client" }
	)
)

local client_keys = awful.util.table.join(
	awful.key({ "Mod4" }, "f", toggle_fullscreen, { description = "Toggle fullscreen", group = "Client" }),

	awful.key({ "Mod1" }, "space", function(c)
		c:kill()
	end, { description = "Kill focused client", group = "Client" }),

	awful.key({ "Mod4" }, "o", move_client_to_next_screen, { description = "Move to next screen", group = "Client" }),

	awful.key({ "Mod4", "Control", "Shift" }, "1",
	function (c)
    if c and screen[2] then
		local screen2 = screen[2]
		if screen2.tags[1] then
			c:move_to_tag(screen2.tags[1])
			screen2.tags[1]:view_only()
		else
		awful.tag
			.add("new", {
				screen = screen2,
				layout = awful.layout.suit.spiral,
				volatile = true,
			})
			c:move_to_tag(screen2.tags[1])
			screen2.tags[1]:view_only()
		end
    end
	end, { description = "Move client to screen 2", group = "Client" }),

	awful.key({ "Mod4", "Control", "Shift" }, "n", function(c)
		local ntag = awful.tag
			.add("new", {
				screen = awful.screen.focused(),
				layout = awful.layout.suit.spiral,
				volatile = true,
			})
		c:move_to_tag(ntag)
		ntag:view_only()
		maximize_client(c)
	end),

	awful.key({ "Mod4" }, "n", minimize_client, { description = "Minimize client", group = "Client" }),

	awful.key({ "Mod4" }, "m", maximize_client, { description = "Maximize client", group = "Client" }),

	awful.key({ "Mod4", "Control", "Mod1" }, "Right", function()
		swap_clients_between_tags(1)
	end, { description = "swap clients with next tag", group = "tag" }),

	awful.key({ "Mod4", "Control", "Mod1" }, "Left", function()
		swap_clients_between_tags(-1)
	end, { description = "swap clients with previous tag", group = "tag" }),

	awful.key(
		{ "Mod4", "Control" },
		"m",
		maximize_client_to_multiple_monitor,
		{ description = "Maximize client to miltiple monitors", group = "Client" }
	),

 	awful.key({ "Mod4", "Shift" }, "Down", function(c)
		snap_edge(c, "bottom")
	end, { description = "Snap client to bottom", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "Left", function(c)
		snap_edge(c, "left")
	end, { description = "Snap client to left", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "Right", function(c)
		snap_edge(c, "right")
	end, { description = "Snap client to right", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "Up", function(c)
		snap_edge(c, "top")
	end, { description = "Snap client to top", group = "Client" }),

	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[1], function(c)
		snap_edge(c, "bottom_left")
	end, { description = "Snap client to bottom-left", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[2], function(c)
		snap_edge(c, "bottom")
	end, { description = "Snap client to bottom", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[3], function(c)
		snap_edge(c, "bottom_right")
	end, { description = "Snap client to bottom-right", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[4], function(c)
		snap_edge(c, "left")
	end, { description = "Snap client to left", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[5], function(c)
		snap_edge(c, "centered")
	end, { description = "Snap client to center", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[6], function(c)
		snap_edge(c, "right")
	end, { description = "Snap client to right", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[7], function(c)
		snap_edge(c, "top_left")
	end, { description = "Snap client to top-left", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[8], function(c)
		snap_edge(c, "top")
	end, { description = "Snap client to top", group = "Client" }),
	awful.key({ "Mod4", "Shift" }, "#" .. vars.numpad_key_codes[9], function(c)
		snap_edge(c, "top_right")
	end, { description = "Snap client to top-right", group = "Client" })
)

for i = 1, 9 do
	client_keys = awful.util.table.join(
		client_keys,
		awful.key({ "Mod4", "Shift" }, "#" .. i + 9, function(c)
			do_for_tag(i, function(tag)
				c:move_to_tag(tag)
			end)
		end, { description = "Move focused client to tag #", group = "Client" })
	)
end

for i = 1, 9 do
	global_keys = awful.util.table.join(
		global_keys,
		awful.key({ "Mod4" }, "#" .. i + 9, function()
			do_for_tag(i, function(tag)
				tag:view_only()
			end)
		end, { description = "View only tag #", group = "Tag" }),
		awful.key({ "Mod4", "Control" }, "#" .. i + 9, function()
			do_for_tag(i, function(tag)
				awful.tag.viewtoggle(tag)
			end)
		end, { description = "Add view tag #", group = "Tag" })
	)
end

awful.menu.menu_keys = {
	up = { "Up" },
	down = { "Down" },
	exec = { "Return", "Space" },
	enter = { "Right" },
	back = { "Left" },
	close = { "Escape" },
}

return {
	global_keys = global_keys,
	client_keys = client_keys,
}
