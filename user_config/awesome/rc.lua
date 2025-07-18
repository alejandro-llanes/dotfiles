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
local wibox = require("wibox")
local vicious = require("vicious")
local beautiful = require("beautiful")
local naughty = require("naughty")
local cairo = require("lgi").cairo

require("modules/error_handling")

local executer = require("modules/executer")
local screens_manager = require("modules/screens_manager")

local config_path = gears.filesystem.get_configuration_dir()

-- | Variable definitions | --
local current_os = get_os_name()[1]
local terminal = "alacritty"
local browser = "google-chrome-stable"
local file_manager = "nautilus"
local graphic_text_editor = "emacs"
local music_player = "spotify"
--local session_lock_command = "dm-tool lock"
local session_lock_command = "xfce4-screensaver-command -l"
local calendar_command = "/opt/google/chrome/google-chrome --profile-directory='Profile 2' --app=https://calendar.google.com/calendar"
local power_manager_settings_command = "xfce4-power-manager-settings"
local system_monitor_command = "gnome-system-monitor"
local network_configuration_command = "nm-connection-editor"
local launch_command = "ulauncher"

--local wallpaper_image_path = config_path .. "/themes/relz/wallpapers/cosmos_purple.jpg";
local wallpaper_image_path = config_path .. "/themes/relz/wallpapers/9matter.jpg";
local geolocation = {
  latitude = 0,
  longitude = 0
}
if current_os == "Linux" then
  local wired_interface = "enp58s0u1u1"
  local wireless_interface = "wlp59s0"
end

if current_os == "FreeBSD" then
  local wired_interface = "em0"
  local wireless_interface = "wlan0"
end

local numpad_key_codes = { 87, 88, 89, 83, 84, 85, 79, 80, 81 }

-- | Widgets | --

beautiful.init(config_path .. "/themes/relz/theme.lua")

local cpu_widget = CpuWidget(false, system_monitor_command)
local memory_widget = MemoryWidget(false, system_monitor_command)
local brightness_widget = BrightnessWidget(true, 100)
local battery_widget = BatteryWidget(true, power_manager_settings_command)
local calendar_widget = CalendarWidget(calendar_command)
local clock_widget = ClockWidget(calendar_command)
local menu_widget = MenuWidget(session_lock_command)
local network_widget = NetworkWidget(false, network_configuration_command)
local bluetooth_widget = BluetoothWidget(true)
local volume_widget = VolumeWidget(true)
local microphone_widget = MicrophoneWidget(true)
local keyboard_layout_widget = KeyboardLayoutWidget()
local launch_widget = LaunchWidget(launch_command)

-- | Functions | --

-- Panels

local task_left_button_press_action = function(c)
  if not is_client_in_tag(c, awful.tag.selected()) then
    return
  end

  if c == client.focus then
    c.minimized = true
  else
    c:emit_signal(
      "request::activate",
      "tasklist",
      { raise = true }
    )
  end
end

-- Brightness

local set_brightness = function(step_percent, increase)
  set_system_brightness(
    step_percent,
    increase,
    function(new_value_percent)
      brightness_widget.update(new_value_percent)
    end
  )
end

-- Volume

local mute = function()
  local command = "amixer -D pulse set Master 1+ toggle"
  awful.spawn.easy_async(command, function() vicious.force({ volume_widget.icon }) end)
end

local set_volume = function(step, increase)
  set_sink_volume(step, increase, function() vicious.force({ volume_widget.icon }) end)
end

-- | Panels | --

local screen_0_panel = Panel()
screen_0_panel.position = "top"

if current_os == "Linux" then
	screen_0_panel.thickness = 32
end
screen_0_panel.tags.list = {
  Tag("1", awful.layout.suit.spiral)--,
--  Tag("2", awful.layout.suit.spiral),
--  Tag("3", awful.layout.suit.spiral),
--  Tag("4", awful.layout.suit.spiral),
--  Tag("5", awful.layout.suit.spiral),
}
screen_0_panel.tags.key_bindings = awful.util.table.join(
  awful.button({}, 1, awful.tag.viewonly),
  awful.button({ "Mod4" }, 1, awful.client.movetotag)
)
screen_0_panel.tasks.key_bindings = awful.util.table.join(
  awful.button({}, 1, task_left_button_press_action)
)
if current_os == "Linux" then
screen_0_panel.widgets = {
  keyboard_layout_widget,
  cpu_widget,
  memory_widget,
  microphone_widget,
  brightness_widget,
  {
    calendar_widget,
    clock_widget,
  },
  menu_widget
}
end
if current_os == "FreeBSD" then
screen_0_panel.widgets = {
  cpu_widget,
  memory_widget,
  network_widget,
  bluetooth_widget,
  volume_widget,
  microphone_widget,
  brightness_widget,
  battery_widget,
  keyboard_layout_widget,
  {
    calendar_widget,
    clock_widget,
  },
  menu_widget
}
end
screen_0_panel.launcher = launch_widget

-- | Screens | --

update_screens = function(card)
  local xrandr_output = run_command_sync("xrandr")
  local primary_output = xrandr_output:match("([a-zA-Z0-9-]+) connected primary")
  if primary_output == nil then
    primary_output = xrandr_output:match("([a-zA-Z0-9-]+) connected")
  end
  local primary_output_rect = xrandr_output:match(primary_output:gsub("-", "[-]") .. " connected[a-z ]* ([0-9x+]+) [(]")

  local is_secondary_output_in_use = false
  local is_screen_duplicated = false

  for _,secondary_output_name in ipairs({"HDMI", "DisplayPort", "DVI", "DP"}) do
    is_secondary_output_in_use = is_secondary_output_in_use or string.match(xrandr_output, secondary_output_name .. "[0-9-]+ connected [^(]") ~= nil
    local unused_secondary_output = xrandr_output:match("(" .. secondary_output_name .. "[0-9-]+) connected [(]")
    local used_secondary_output = xrandr_output:match("(" .. secondary_output_name .. "[0-9-]+) connected [^(]")
    local used_secondary_output_rect = xrandr_output:match(secondary_output_name .. "[0-9-]+ connected[a-z ]* ([0-9x+]+) [(]")
    local disconnected_secondary_output_rect = xrandr_output:match(secondary_output_name .. "[0-9-]+ disconnected[a-z ]* ([0-9x+]+) [(]")
    local is_secondary_output_disconnected = unused_secondary_output == nil and used_secondary_output == nil
    is_screen_duplicated = is_screen_duplicated or primary_output_rect == used_secondary_output_rect

    if (not is_secondary_output_in_use and unused_secondary_output) or is_screen_duplicated then
      local secondary_output = is_screen_duplicated and used_secondary_output or unused_secondary_output

      run_command_sync(
        "xrandr " ..
        "--output " .. primary_output .. " --preferred --primary " ..
        "--output " .. secondary_output .. " --right-of " .. primary_output .. " --preferred "
      )
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

update_screens()

screen.connect_signal("added", function()
  if screen.count() > screens_manager.get_screen_count() then
    local newScreen = Screen()
    newScreen.wallpaper = wallpaper_image_path
    newScreen.panels = { screen_0_panel }

    screens_manager.add_screen(newScreen)
  end
  screens_manager.apply_screen(screens_manager.get_screen_count())
end)

local toggle_panel = function()
  local panel_ref = awful.screen.focused().panel
  if panel_ref ~= nil and panel_ref.visible ~= nil then
    panel_ref.visible = not panel_ref.visible
  end
end

--local inspect = require("modules/inspect")

client.connect_signal("manage", function(c)
    if c and c.valid and not c.icon and class_icons[c.class] then
        naughty.notify({text =  c.class .. " does not have valid icon." })
        local sf = gears.surface(class_icons[c.class])
        local img = cairo.ImageSurface.create(cairo.Format.ARGB32, sf:get_width(), sf:get_height())
        local cr = cairo.Context(img)
        cr:set_source_surface(sf, 0, 0)
        cr:paint()
        c.icon = img and img._native or nil
    end
end)


-- | Key bindings | --

local global_keys = gears.table.join(
  awful.key({ "Mod4" }, "/", show_help, { description="Show hotkeys", group="Awesome" }),
  awful.key({ "Mod4" }, ".", show_help),

  awful.key({ "Mod4", "Mod1" }, "t", function()
      naughty.notify({title="test os",text=tostring(current_os)})
  end ),

  awful.key({ "Mod4" }, "x", function() awful.spawn("rofi -show drun -columns 3")  end, {description="Launcher", group = "launcher"}),
  awful.key({ "Mod4", "Shift" }, "e", function() repl_modal()  end, {description="Modal Code Eval", group = "Awesome"}),
  awful.key({ "Mod4", "Shift" }, "b", function() toggle_panel()  end, {description="Toggle Panel", group = "Awesome"}),

  awful.key({"Mod4", "Control", "Shift"}, "n", function()
      awful.tag.add("new", {
                      screen = awful.screen.focused(),
                      layout = awful.layout.suit.spiral,
                      volatile = true,
      }):view_only()
  end ),
  
  awful.key({ "Mod4" }, "Tab", function() change_focused_client(1) end, { description="Change focused client to next", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "Tab", function() change_focused_client(-1) end, { description="Change focused client to previous", group="Client" }),

  awful.key({ "Control", "Mod1" }, "Left",  function() awful.tag.viewidx(-1) end),
  awful.key({ "Control", "Mod1" }, "Right", function() awful.tag.viewidx(1) end),

  awful.key({ "Mod4", "Control" }, "r", awesome.restart, { description="Restart awesome", group="Awesome" }),

  awful.key({ "Mod4", "Shift" }, "q", awesome.quit, { description="Quit awesome", group="Awesome" }),

  awful.key({"Control", "Mod1" }, "l", function() awful.spawn(session_lock_command) end, { description="Lock the session", group="Session" }),

  awful.key({ "Mod4" }, "Return", function() awful.spawn(terminal) end, { description="Execute default terminal (" .. terminal .. ")", group="Application" }),

  awful.key({}, "XF86MonBrightnessUp", function() set_brightness(5, true) end, { description="Increase brightness by 5", group="Brightness" }),
  awful.key({}, "XF86MonBrightnessDown", function() set_brightness(5, false) end, { description="Decrease brightness by 5", group="Brightness" }),

  awful.key({ "Control" }, "XF86MonBrightnessUp", function() set_brightness(10, true) end, { description="Increase brightness by 10", group="Brightness" }),
  awful.key({ "Control" }, "XF86MonBrightnessDown", function() set_brightness(10, false) end, { description="Decrease brightness by 10", group="Brightness" }),

  awful.key({}, "XF86AudioMute", function() mute() end, { description="Toggle sound volume", group="Volume" }),

  awful.key({}, "XF86AudioRaiseVolume", function() set_volume(5, true) end, { description="Raise volume by 5", group="Volume" }),
  awful.key({}, "XF86AudioLowerVolume", function() set_volume(5, false) end, { description="Lower volume by 5", group="Volume" }),

  awful.key({ "Control" }, "XF86AudioRaiseVolume", function() set_volume(10, true) end, { description="Raise volume by 10", group="Volume" }),
  awful.key({ "Control" }, "XF86AudioLowerVolume", function() set_volume(10, false) end, { description="Lower volume by 10", group="Volume" }),

  awful.key({}, "XF86AudioPrev", function() audio_previous() end, { description="Previous audio", group="Audio" }),
  awful.key({}, "XF86AudioPlay", function() audio_toggle_play_pause() end, { description="Play/Pause audio", group="Audio" }),
  awful.key({}, "XF86AudioNext", function() audio_next() end, { description="Next audio", group="Audio" }),
  awful.key({}, "XF86AudioStop", function() audio_stop() end, { description="Stop audio", group="Audio" }),

  -- Applications running
  -- awful.key({ "Mod4", "Control", "Shift" }, "b", function() awful.spawn(browser) end, { description="Execute default web browser (" .. browser .. ")", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "t", function() awful.spawn("telegram-desktop") end, { description="Execute Telegram", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "l", function() awful.spawn("libreoffice") end, { description="Execute LibreOffice", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "e", function() awful.spawn(graphic_text_editor) end, { description="Execute default graphic text editor (" .. graphic_text_editor .. ")", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "m", function() awful.spawn(music_player) end, { description="Execute default music player (" .. music_player .. ")", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "f", function() awful.spawn(file_manager) end, { description="Execute default file manager (" .. file_manager .. ")", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "j", function() awful.spawn("jetbrains-toolbox") end, { description="Execute Jetbrains-Toolbox", group="Application" }),

  awful.key({ "Mod4" }, "k", function() awful.spawn("xkill") end, { description="Execute XKill", group="Application" }),

  awful.key({ "Mod4" }, "\\", function() awful.spawn("arandr") end, { description="Execute ARandr", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "d", function() awful.spawn("discord") end, { description="Execute Discord", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "]", function() awful.spawn("obs") end, { description="Execute OBS Studio", group="Application" }),

  -- awful.key({ }, "Print", function() awful.spawn("deepin-screenshot --no-notification --fullscreen") end, { description="Take a screenshot the whole screen", group="Application" }),
  -- awful.key({ "Mod4" }, "Print", function() awful.util.spawn_with_shell("sleep 2 && deepin-screenshot --no-notification --fullscreen") end, { description="Take a screenshot the whole screen after 2 seconds", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "s", function() awful.spawn("deepin-screenshot --no-notification") end, { description="Execute Deepin Screen Capture", group="Application" }),

--  awful.key({ "Mod4", "Control", "Shift" }, "v", function() awful.spawn("viber") end, { description="Execute Viber", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "`", function() awful.spawn(system_monitor_command) end, { description="Execute System Monitor (" .. system_monitor_command .. ")", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "k", function() awful.spawn("gitkraken") end, { description="Execute GitKraken", group="Application" }),

  -- awful.key({ "Mod4", "Control", "Shift" }, "c", function() awful.spawn("code") end, { description="Execute VSCode", group="Application" }),

  awful.key({ "Mod4" }, "d", toogle_minimize_restore_clients, { description="Toggle minimize restore clients", group="Client" })

)

local client_keys = awful.util.table.join(
  awful.key({ "Mod4" }, "f", toggle_fullscreen, { description="Toggle fullscreen", group="Client" }),

  awful.key({ "Mod1" }, "space", function(c) c:kill() end, { description="Kill focused client", group="Client" }),

  awful.key({ "Mod4" }, "o", move_client_to_next_screen, { description="Move to next screen", group="Client" }),

  awful.key({ "Mod4" }, "n", minimize_client, { description="Minimize client", group="Client" }),

  awful.key({ "Mod4" }, "m", maximize_client, { description="Maximize client", group="Client" }),

  awful.key({ "Mod4", "Control", "Mod1" }, "Right", function()
    swap_clients_between_tags(1) end,
    {description = "swap clients with next tag", group = "tag"}),

  awful.key({ "Mod4", "Control", "Mod1" }, "Left", function()
    swap_clients_between_tags(-1) end,
    {description = "swap clients with previous tag", group = "tag"}),

  awful.key({ "Mod4", "Control" }, "m", maximize_client_to_multiple_monitor, { description="Maximize client to miltiple monitors", group="Client" }),

  -- Snap to edge/corner - Use arrow keys
  awful.key({ "Mod4", "Shift" }, "Down",  function(c) snap_edge(c, 'bottom') end, { description="Snap client to bottom", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "Left",  function(c) snap_edge(c, 'left') end, { description="Snap client to left", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "Right", function(c) snap_edge(c, 'right') end, { description="Snap client to right", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "Up",    function(c) snap_edge(c, 'top') end, { description="Snap client to top", group="Client" }),

  -- Snap to edge/corner - Use numpad
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[1], function(c) snap_edge(c, 'bottom_left') end, { description="Snap client to bottom-left", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[2], function(c) snap_edge(c, 'bottom') end, { description="Snap client to bottom", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[3], function(c) snap_edge(c, 'bottom_right') end, { description="Snap client to bottom-right", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[4], function(c) snap_edge(c, 'left') end, { description="Snap client to left", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[5], function(c) snap_edge(c, 'centered') end, { description="Snap client to center", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[6], function(c) snap_edge(c, 'right') end, { description="Snap client to right", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[7], function(c) snap_edge(c, 'top_left') end, { description="Snap client to top-left", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[8], function(c) snap_edge(c, 'top') end, { description="Snap client to top", group="Client" }),
  awful.key({ "Mod4", "Shift" }, "#" .. numpad_key_codes[9], function(c) snap_edge(c, 'top_right') end, { description="Snap client to top-right", group="Client" })
)

for i = 1, 9 do
  client_keys = awful.util.table.join(client_keys,
    awful.key({ "Mod4", "Shift"   }, "#" .. i + 9, function(c) do_for_tag(i, function(tag) c:move_to_tag(tag) end) end, { description="Move focused client to tag #", group="Client" })
  )
end

for i = 1, 9 do
  global_keys = awful.util.table.join(global_keys,
    awful.key({ "Mod4"            }, "#" .. i + 9, function() do_for_tag(i, function(tag) tag:view_only() end) end, { description="View only tag #", group="Tag" }),
    awful.key({ "Mod4", "Control" }, "#" .. i + 9, function() do_for_tag(i, function(tag) awful.tag.viewtoggle(tag) end) end, { description="Add view tag #", group="Tag" })
  )
end

swap_clients_between_tags = function(direction)
    local screen = awful.screen.focused()
    local tags = screen.tags
    local current_tag = screen.selected_tag
    if not current_tag then return end

    local index = current_tag.index
    local next_index = index + direction

    if next_index < 1 or next_index > #tags then return end

    local target_tag = tags[next_index]
    local current_clients = current_tag:clients()
    local target_clients = target_tag:clients()

    -- Backup and disable volatile
    local was_current_volatile = current_tag.volatile
    local was_target_volatile = target_tag.volatile
    current_tag.volatile = false
    target_tag.volatile = false

    -- Swap clients
    for _, c in ipairs(current_clients) do
        c:move_to_tag(target_tag)
    end
    for _, c in ipairs(target_clients) do
        c:move_to_tag(current_tag)
    end

    -- Restore volatile status
    current_tag.volatile = was_current_volatile
    target_tag.volatile = was_target_volatile

    -- Focus the target tag
    target_tag:view_only()
end


awful.menu.menu_keys = {
  up    = { "Up" },
  down  = { "Down" },
  exec  = { "Return", "Space" },
  enter = { "Right" },
  back  = { "Left" },
  close = { "Escape" }
}

root.keys(global_keys)

-- | Rules | --

local function hide_dropdowns()
  menu_widget.hide_dropdown()
  volume_widget.hide_dropdown()
  brightness_widget.hide_dropdown()
end

local client_buttons = awful.util.table.join(
  awful.button({ }, 1, hide_dropdowns),
  awful.button({ }, 2, hide_dropdowns),
  awful.button({ }, 3, hide_dropdowns),
  awful.button({ "Mod4" }, 1, move_client),
  awful.button({ "Mod4" }, 3, resize_client)
)

local hotkeys_popup = require("awful.hotkeys_popup.widget")
hotkeys_popup.add_hotkeys({
  ["Client"] = {{
    modifiers = {"Mod4"},
    keys = {
        LMB="Move focused client",
        RMB="Resize focused client"
    }
  }}
})
hotkeys_popup.add_group_rules("Client")

client.connect_signal("property::urgent", function(c)
    if c.urgent then
        local t = c.first_tag
        if t then
            t:view_only()
        end
    end
end)

awful.rules.rules = {
  {
    rule = { },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = client_keys,
      buttons = client_buttons,
      titlebars_enabled = false,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen,
      --tag = "5"
    }
  },
  {
    rule_any = {},
    except_any = { type = {"normal"}, class = {"Emacs"} },
    properties = {
      floating = true,
      skip_taskbar = true,
      ontop = true,
      focusable = false,
    },
    callback = function(c)
      awful.placement.centered(c.focus)
    end
  },
  {
    rule = { class = "Alacritty" },
    properties = {
      tag = "1",
      switchtotag = true,
      focus = true
    }
  },
  -- {
  --   rule = { class = "Microsoft-edge" },
  --   properties = {
  --     tag = "2",
  --     switchtotag = true,
  --     focus = true
  --   }
  -- },
  -- {
  --   rule = { class = "Emacs" },
  --   properties = {
  --     tag = "3",
  --     switchtotag = true,
  --     focus = true
  --   }
  -- },
  -- {
  --   rule = { class = "Spotify" },
  --   properties = {
  --     tag = "4",
  --     switchtotag = true,
  --     focus = true
  --   }
  -- },
  {
    rule_any = { type = { "normal" }, class = { "Emacs" } },
    except_any = { class = {"Alacritty"} },
    properties = {
      maximized  = true,
      switchtotag = true,
      focus = true,
      new_tag = {
        volatile = true,
        layout = awful.layout.suit.spiral,
        --screen = 0
      }
    }
  }

}

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- Default buttons for the titlebar
  local buttons = awful.util.table.join(
    awful.button({ }, 1, function() move_client(c) end),
    awful.button({ }, 3, function() resize_client(c) end)
  )

  awful.titlebar(c, {size = 24}) : setup {
    { -- Left
      wibox.container.margin(awful.titlebar.widget.closebutton(c), 0, 0, 2, 2),
      wibox.container.margin(awful.titlebar.widget.maximizedbutton(c), 0, 0, 2, 2),
      wibox.container.margin(awful.titlebar.widget.minimizebutton(c), 0, 0, 2, 2),
      layout = wibox.layout.fixed.horizontal
    },
    { -- Middle
      { -- Title
        align  = "center",
        widget = awful.titlebar.widget.titlewidget(c)
      },
      buttons = buttons,
      layout  = wibox.layout.flex.horizontal
    },
    { -- Right
      buttons = buttons,
      layout = wibox.layout.fixed.horizontal()
    },
      layout = wibox.layout.align.horizontal
  }
end)

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

-- | Initialization | --

local redshift_config_directory = gears.filesystem.get_xdg_config_home() .. "redshift"

if not gears.filesystem.dir_readable(redshift_config_directory) then
  gears.filesystem.make_directories(redshift_config_directory)
end

local redshift_config_path = redshift_config_directory .. "/redshift.conf"

if not gears.filesystem.file_readable(redshift_config_path) then
  write_file_content(redshift_config_directory .. "/redshift.conf", "[redshift]\n")
end


get_system_brightness(function(value_percent)
  brightness_widget.update(value_percent)
end)

if geolocation.latitude == 0 and geolocation.longitude == 0 then
  local latitude_string = read_file_content(gears.filesystem.get_configuration_dir() .. "latitude")
  local longitude_string = read_file_content(gears.filesystem.get_configuration_dir() .. "longitude")

  geolocation.latitude = tonumber(latitude_string) or 0
  geolocation.longitude = tonumber(longitude_string) or 0

  if geolocation.latitude == 0 and geolocation.longitude == 0 then
    get_geolocation(function(latitude, longitude)
      require("naughty").notify({title=longitude})
      geolocation.latitude = latitude
      geolocation.longitude = longitude

      write_file_content(gears.filesystem.get_configuration_dir() .. "latitude", geolocation.latitude)
      write_file_content(gears.filesystem.get_configuration_dir() .. "longitude", geolocation.longitude)

      brightness_widget.set_geolocation(geolocation)
    end)
  else
    brightness_widget.set_geolocation(geolocation)
  end
else
  brightness_widget.set_geolocation(geolocation)
end

if wired_interface == nil then
  wired_interface = read_file_content(gears.filesystem.get_configuration_dir() .. "wired_interface")

  if wired_interface == nil then
    get_wired_interface(function(value)
      wired_interface = value
      write_file_content(gears.filesystem.get_configuration_dir() .. "wired_interface", wired_interface)
      network_widget.set_wired_interface(wired_interface)
    end)
  else
    network_widget.set_wired_interface(wired_interface)
  end
else
  network_widget.set_wired_interface(wired_interface)
end

if wireless_interface == nil then
  wireless_interface = read_file_content(gears.filesystem.get_configuration_dir() .. "wireless_interface")

  if wireless_interface == nil then
    get_wireless_interface(function(value)
      wireless_interface = value
      write_file_content(gears.filesystem.get_configuration_dir() .. "wireless_interface", wireless_interface)
      network_widget.set_wireless_interface(wireless_interface)
    end)
  else
    network_widget.set_wireless_interface(wireless_interface)
  end
else
  network_widget.set_wireless_interface(wireless_interface)
end

-- | Autostart | --


if current_os == "Linux" then
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
 -- "/usr/bin/1password --silent"
})
end

if current_os == "FreeBSD" then
	executer.execute_commands({
  "xmodmap -e 'pointer = 3 2 1'",
  "setxkbmap -layout latam",
  "picom",
  "pasystray",
  "xfce4-power-manager",
  "xfce4-screensaver"
  --"picom --usr backend",
  --"/glx/lib/mate-polkit/polkit-mate-authentication-agent-1",
  --"/usr/lib/geoclue-2.0/demos/agent",
  --"xfce4-clipman",
  --"nm-applet",
  --"ulauncher"
})

end
