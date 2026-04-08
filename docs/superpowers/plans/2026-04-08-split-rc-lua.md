# Split rc.lua into Topic-Based Config Files

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make rc.lua more readable by splitting its 927 lines into 9 topic-based config modules that each return a table of exports, reducing rc.lua to ~50 lines of requires and wiring.

**Architecture:** Each new file under `config/` returns a table of exports (variables, functions, widgets). `rc.lua` requires each config module and wires dependencies explicitly. Global functions from `utils.lua` and `helper.lua` remain accessible since they're loaded first. The module pattern follows the existing convention used by `modules/executer.lua` (local table + return).

**Tech Stack:** Lua, AwesomeWM API (awful, gears, wibox, naughty, vicious, lgi.cairo)

---

### Task 1: Create config directory and variables.lua

**Files:**
- Create: `config/variables.lua`

- [ ] **Step 1: Create config/ directory**

```bash
mkdir -p /home/alejandro/dotfiles/user_config/awesome/config
```

- [ ] **Step 2: Create config/variables.lua**

Extract lines 41-75 from rc.lua (variable definitions, OS detection, numpad codes).

Fix the scoping bug: `wired_interface` and `wireless_interface` are declared `local` inside `if` blocks (lines 66-68, 70-73), making them nil outside. Move them to top-level and set conditionally.

Also include the `config_path` variable and `session_lock_command`, `calendar_command`, etc.

```lua
local gears = require("gears")

local config_path = gears.filesystem.get_configuration_dir()

local current_os = get_os_name()[1]

local wired_interface = nil
local wireless_interface = nil

if current_os == "Linux" then
	wired_interface = "enp58s0u1u1"
	wireless_interface = "wlp59s0"
end

if current_os == "FreeBSD" then
	wired_interface = "em0"
	wireless_interface = "wlan0"
end

local numpad_key_codes = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }

return {
	config_path = config_path,
	current_os = current_os,
	terminal = "alacritty",
	browser = "google-chrome-stable",
	file_manager = "nautilus",
	graphic_text_editor = "emacs",
	music_player = "spotify",
	session_lock_command = "xfce4-screensaver-command -l",
	calendar_command = "",
	power_manager_settings_command = "xfce4-power-manager-settings",
	system_monitor_command = "gnome-system-monitor",
	network_configuration_command = "nm-connection-editor",
	launch_command = "ulauncher",
	wallpaper_image_path = config_path .. "/themes/relz/wallpapers/tokyo.jpg",
	geolocation = {
		latitude = 0,
		longitude = 0,
	},
	wired_interface = wired_interface,
	wireless_interface = wireless_interface,
	numpad_key_codes = numpad_key_codes,
}
```

- [ ] **Step 3: Commit**

```bash
git add config/variables.lua
git commit -m "feat: extract variables into config/variables.lua"
```

---

### Task 2: Create config/widgets.lua

**Files:**
- Create: `config/widgets.lua`

- [ ] **Step 1: Create config/widgets.lua**

Extract lines 77-93 from rc.lua (widget instantiation). Requires `config/variables` for command strings.

```lua
local vars = require("config.variables")

local cpu_widget = CpuWidget(false, vars.system_monitor_command)
local memory_widget = MemoryWidget(false, vars.system_monitor_command)
local brightness_widget = BrightnessWidget(true, 100)
local battery_widget = BatteryWidget(true, vars.power_manager_settings_command)
local calendar_widget = CalendarWidget(vars.calendar_command)
local clock_widget = ClockWidget(vars.calendar_command)
local menu_widget = MenuWidget(vars.session_lock_command)
local network_widget = NetworkWidget(false, vars.network_configuration_command)
local bluetooth_widget = BluetoothWidget(true)
local volume_widget = VolumeWidget(true)
local microphone_widget = MicrophoneWidget(true)
local keyboard_layout_widget = KeyboardLayoutWidget()
local launch_widget = LaunchWidget(vars.launch_command)

return {
	cpu_widget = cpu_widget,
	memory_widget = memory_widget,
	brightness_widget = brightness_widget,
	battery_widget = battery_widget,
	calendar_widget = calendar_widget,
	clock_widget = clock_widget,
	menu_widget = menu_widget,
	network_widget = network_widget,
	bluetooth_widget = bluetooth_widget,
	volume_widget = volume_widget,
	microphone_widget = microphone_widget,
	keyboard_layout_widget = keyboard_layout_widget,
	launch_widget = launch_widget,
}
```

- [ ] **Step 2: Commit**

```bash
git add config/widgets.lua
git commit -m "feat: extract widgets into config/widgets.lua"
```

---

### Task 3: Create config/panels.lua

**Files:**
- Create: `config/panels.lua`

- [ ] **Step 1: Create config/panels.lua**

Extract lines 96-185 from rc.lua (panel functions + panel layout per OS). Requires `config.widgets` and `config.variables`.

```lua
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
		{
			widgets.calendar_widget,
			widgets.clock_widget,
		},
		widgets.menu_widget,
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
```

- [ ] **Step 2: Commit**

```bash
git add config/panels.lua
git commit -m "feat: extract panels into config/panels.lua"
```

---

### Task 4: Create config/screens.lua

**Files:**
- Create: `config/screens.lua`

- [ ] **Step 1: Create config/screens.lua**

Extract lines 187-273 from rc.lua (screen setup, xrandr, multi-monitor). The `update_screens` function and screen signal handler move here. Exports a `setup()` function that wires everything.

```lua
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
```

- [ ] **Step 2: Commit**

```bash
git add config/screens.lua
git commit -m "feat: extract screens into config/screens.lua"
```

---

### Task 5: Create config/keys.lua

**Files:**
- Create: `config/keys.lua`

- [ ] **Step 1: Create config/keys.lua**

Extract lines 289-641 from rc.lua (all key bindings, `swap_clients_between_tags`, menu keys). This is the largest section. Requires `config.variables` and `config.widgets`.

The `set_brightness`, `mute`, `set_volume`, `toggle_panel`, and `swap_clients_between_tags` functions are defined locally since they're only used within this file.

Note: `numpad_key_codes` is accessed via `vars.numpad_key_codes`.

```lua
local awful = require("awful")
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
```

Note: `global_keys` and `client_keys` must be declared with `local` initially, but since they're mutated in loops (lines 564-589), the same pattern from rc.lua is followed where the loops append to them. This works because Lua closures capture the variable reference.

- [ ] **Step 2: Commit**

```bash
git add config/keys.lua
git commit -m "feat: extract key bindings into config/keys.lua"
```

---

### Task 6: Create config/rules.lua

**Files:**
- Create: `config/rules.lua`

- [ ] **Step 1: Create config/rules.lua**

Extract lines 643-802 from rc.lua (client rules, client buttons, hide_dropdowns, hotkeys popup, titlebars). Requires `config.keys` for `client_keys`.

The `hide_dropdowns` function needs widget references, so it's defined here but calls widget methods directly. To avoid a circular dependency (rules → widgets → variables is fine, but rules → keys → widgets creates keys → widgets), we pass widgets in via a setup function.

Actually, inspecting more carefully: `client_buttons` doesn't need widgets. `hide_dropdowns` needs `menu_widget`, `volume_widget`, `brightness_widget`. The `client_keys` come from `config.keys`. So we can require `config.keys` directly for `client_keys`, but we need to receive widgets for `hide_dropdowns`.

Let's pass the widget references that `hide_dropdowns` needs as a parameter to a setup function:

```lua
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
```

- [ ] **Step 2: Commit**

```bash
git add config/rules.lua
git commit -m "feat: extract rules and titlebars into config/rules.lua"
```

---

### Task 7: Create config/signals.lua

**Files:**
- Create: `config/signals.lua`

- [ ] **Step 1: Create config/signals.lua**

Extract lines 277-287 (client icon fallback) and lines 673-680 (property::urgent), 804-815 (manage mouse enter focus) from rc.lua.

The client icon signal needs `class_icons` (from `modules/icons`) and `naughty`, `gears`, `cairo`. The urgent signal doesn't need external deps. The manage/focus signal doesn't either.

```lua
local gears = require("gears")
local naughty = require("naughty")
local cairo = require("lgi").cairo

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
```

Note: `awful` is a global in awesome WM context but should still be required for correctness.

- [ ] **Step 2: Commit**

```bash
git add config/signals.lua
git commit -m "feat: extract signals into config/signals.lua"
```

---

### Task 8: Create config/initialization.lua

**Files:**
- Create: `config/initialization.lua`

- [ ] **Step 1: Create config/initialization.lua**

Extract lines 817-890 from rc.lua (redshift setup, geolocation, network interfaces). This module needs `vars` and `widgets`.

```lua
local gears = require("gears")

local M = {}

M.run = function(vars, widgets)
	local redshift_config_directory = gears.filesystem.get_xdg_config_home() .. "redshift"

	if not gears.filesystem.dir_readable(redshift_config_directory) then
		gears.filesystem.make_directories(redshift_config_directory)
	end

	local redshift_config_path = redshift_config_directory .. "/redshift.conf"

	if not gears.filesystem.file_readable(redshift_config_path) then
		write_file_content(redshift_config_directory .. "/redshift.conf", "[redshift]\n")
	end

	get_system_brightness(function(value_percent)
		widgets.brightness_widget.update(value_percent)
	end)

	if vars.geolocation.latitude == 0 and vars.geolocation.longitude == 0 then
		local latitude_string = read_file_content(gears.filesystem.get_configuration_dir() .. "latitude")
		local longitude_string = read_file_content(gears.filesystem.get_configuration_dir() .. "longitude")

		vars.geolocation.latitude = tonumber(latitude_string) or 0
		vars.geolocation.longitude = tonumber(longitude_string) or 0

		if vars.geolocation.latitude == 0 and vars.geolocation.longitude == 0 then
			get_geolocation(function(latitude, longitude)
				require("naughty").notify({ title = tostring(longitude) })
				vars.geolocation.latitude = latitude
				vars.geolocation.longitude = longitude

				write_file_content(gears.filesystem.get_configuration_dir() .. "latitude", vars.geolocation.latitude)
				write_file_content(gears.filesystem.get_configuration_dir() .. "longitude", vars.geolocation.longitude)

				widgets.brightness_widget.set_geolocation(vars.geolocation)
			end)
		else
			widgets.brightness_widget.set_geolocation(vars.geolocation)
		end
	else
		widgets.brightness_widget.set_geolocation(vars.geolocation)
	end

	if vars.wired_interface == nil then
		vars.wired_interface = read_file_content(gears.filesystem.get_configuration_dir() .. "wired_interface")

		if vars.wired_interface == nil then
			get_wired_interface(function(value)
				vars.wired_interface = value
				write_file_content(gears.filesystem.get_configuration_dir() .. "wired_interface", vars.wired_interface)
				widgets.network_widget.set_wired_interface(vars.wired_interface)
			end)
		else
			widgets.network_widget.set_wired_interface(vars.wired_interface)
		end
	else
		widgets.network_widget.set_wired_interface(vars.wired_interface)
	end

	if vars.wireless_interface == nil then
		vars.wireless_interface = read_file_content(gears.filesystem.get_configuration_dir() .. "wireless_interface")

		if vars.wireless_interface == nil then
			get_wireless_interface(function(value)
				vars.wireless_interface = value
				write_file_content(gears.filesystem.get_configuration_dir() .. "wireless_interface", vars.wireless_interface)
				widgets.network_widget.set_wireless_interface(vars.wireless_interface)
			end)
		else
			widgets.network_widget.set_wireless_interface(vars.wireless_interface)
		end
	else
		widgets.network_widget.set_wireless_interface(vars.wireless_interface)
	end
end

return M
```

- [ ] **Step 2: Commit**

```bash
git add config/initialization.lua
git commit -m "feat: extract initialization into config/initialization.lua"
```

---

### Task 9: Create config/autostart.lua

**Files:**
- Create: `config/autostart.lua`

- [ ] **Step 1: Create config/autostart.lua**

Extract lines 892-927 from rc.lua (OS-specific autostart commands).

```lua
local executer = require("modules.executer")

local M = {}

M.run = function(vars)
	if vars.current_os == "Linux" then
		executer.execute_commands({
			"xmodmap -e 'pointer = 3 2 1'",
			"picom",
			"nm-applet",
			"blueman-applet",
			"pasystray",
			"xfce4-power-manager",
			"xfce4-screensaver",
			"xfce4-clipman",
			"/usr/libexec/polkit-gnome-authentication-agent-1",
		})
	end

	if vars.current_os == "FreeBSD" then
		executer.execute_commands({
			"xmodmap -e 'pointer = 3 2 1'",
			"setxkbmap -layout latam",
			"picom",
			"pasystray",
			"xfce4-power-manager",
			"xfce4-screensaver",
		})
	end
end

return M
```

- [ ] **Step 2: Commit**

```bash
git add config/autostart.lua
git commit -m "feat: extract autostart into config/autostart.lua"
```

---

### Task 10: Rewrite rc.lua

**Files:**
- Modify: `rc.lua` (replace entire content)

- [ ] **Step 1: Rewrite rc.lua**

Replace the entire contents of rc.lua with the orchestrator. This is the moment of truth — all previously extracted code comes together here.

```lua
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

require("awful.autofocus")

local gears = require("gears")
local beautiful = require("beautiful")

require("modules/error_handling")

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
```

Note: `awful` is used at the global scope by AwesomeWM, so `require("awful")` isn't strictly needed at the top of rc.lua since the WM makes it available, but it's good practice. However, since the original rc.lua uses `local awful = require("awful")` on line 25, we should add it back. Actually, looking at the new rc.lua, `awful` is only used in `awful.rules.rules = ...` which is a global assignment. Let's add the require to be safe.

Revised rc.lua with `awful` required:

```lua
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
```

- [ ] **Step 2: Verify AwesomeWM loads the config without errors**

Restart awesome WM or run a syntax check:
```bash
awesome -k
```
Or check the Lua syntax:
```bash
luac -p /home/alejandro/dotfiles/user_config/awesome/rc.lua
```

- [ ] **Step 3: Commit**

```bash
git add rc.lua
git commit -m "feat: rewrite rc.lua as orchestrator requiring config modules"
```

---

### Task 11: Verify all config files parse correctly

**Files:** All config/* files + rc.lua

- [ ] **Step 1: Run Lua syntax check on all new files**

```bash
for f in config/variables.lua config/widgets.lua config/panels.lua config/screens.lua config/keys.lua config/rules.lua config/signals.lua config/initialization.lua config/autostart.lua; do
  echo "Checking $f..."
  luac -p "$f" && echo "OK" || echo "FAIL"
done
luac -p rc.lua && echo "rc.lua OK" || echo "rc.lua FAIL"
```

- [ ] **Step 2: Fix any syntax errors found**

Address any issues reported by `luac -p`.

- [ ] **Step 3: Commit fixes if any**

```bash
git add -A
git commit -m "fix: resolve Lua syntax errors in config modules"
```