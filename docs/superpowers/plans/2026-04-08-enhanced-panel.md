# Enhanced AwesomeWM Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the AwesomeWM panel with modern minimal aesthetics + cyberpunk glow effects, add new widgets (media controller, clipboard), and enhance existing widgets with animations and visual polish.

**Architecture:** Extend existing widget class pattern (`createClass` prototype) to add glow effects via CSS-like styling in wibox. New widgets follow the same structure. Panel layout changes from edge-attached to floating island with rounded corners and blur.

**Tech Stack:** Lua, AwesomeWM API (wibox, gears, awful, beautiful), MPRIS (D-Bus) for media control, clipman for clipboard history, picom for blur effects.

---

### Task 1: Update theme.lua with glow colors and animation properties

**Files:**
- Modify: `user_config/awesome/themes/relz/theme.lua`

- [ ] **Step 1: Add glow colors and animation properties to theme**

Add these lines after line 32 (`theme.bg_urgent = theme.background_color`):

```lua
-- | Glow Effects | --

theme.glow_cyan = "#00E4C5"
theme.glow_purple = "#9D7AD4"
theme.glow_danger = "#db5853"
theme.glow_blur = dpi(3)
theme.glow_spread = dpi(2)

-- | Animations | --

theme.animation_duration_fast = 0.1
theme.animation_duration_normal = 0.15
theme.animation_duration_slow = 0.3

-- | Panel | --

theme.panel_border_radius = dpi(8)
theme.panel_bg = theme.background_color .. "ee"
theme.widget_spacing = dpi(4)
```

- [ ] **Step 2: Commit**

```bash
git add user_config/awesome/themes/relz/theme.lua
git commit -m "feat: add glow colors and animation properties to theme"
```

---

### Task 2: Create media_widget.lua (MPRIS controller)

**Files:**
- Create: `user_config/awesome/modules/widgets/media_widget.lua`

- [ ] **Step 1: Create media_widget.lua**

```lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

MediaWidget_prototype = function()
  local this = {}

  this.__public_static = {
    config_path = gears.filesystem.get_configuration_dir()
  }

  this.__public = {
    name = "MediaWidget",
    icon = wibox.widget.imagebox(),
    value = wibox.widget.textbox(),
    on_container_created = function(container, panel_position)
      container:buttons(
        awful.util.table.join(
          awful.button({}, 1, function() this.__private.toggle_playback() end),
          awful.button({}, 4, function() this.__private.next_track() end),
          awful.button({}, 5, function() this.__private.prev_track() end)
        )
      )
      this.__private.update()
    end
  }

  this.__private = {
    player_name = "",
    track_title = "",
    track_artist = "",
    playback_status = "Stopped",
    has_album_art = false,
    update = function()
      awful.spawn.easy_async("playerctl metadata --format '{{playerName}}|{{title}}|{{artist}}|{{status}}|{{mpris:artUrl}}'", function(output)
        local parts = {}
        for part in output:gmatch("([^\n|]*)") do
          table.insert(parts, part)
        end
        
        this.__private.player_name = parts[1] or ""
        this.__private.track_title = parts[2] or ""
        this.__private.track_artist = parts[3] or ""
        this.__private.playback_status = parts[4] or ""
        this.__private.has_album_art = (parts[5] or "") ~= ""
        
        this.__private.update_display()
      end)
    end,
    update_display = function()
      if this.__private.playback_status == "" or this.__private.playback_status == "Stopped" then
        this.__public.icon.visible = false
        this.__public.value.visible = false
        return
      end
      
      this.__public.icon.visible = true
      this.__public.value.visible = true
      
      local icon_file = this.__private.playback_status == "Playing" and "media_playing" or "media_paused"
      this.__public.icon.image = gears.color.recolor_image(
        this.__public_static.config_path .. "/themes/relz/icons/widgets/" .. icon_file .. ".svg",
        beautiful.text_color
      )
      
      local display_text = ""
      if this.__private.track_title ~= "" then
        display_text = this.__private.track_title
        if this.__private.track_artist ~= "" then
          display_text = display_text .. " - " .. this.__private.track_artist
        end
      else
        display_text = this.__private.player_name
      end
      
      this.__public.value.text = " " .. display_text .. " "
      this.__public.value.font = beautiful.font_family_mono .. "Bold 9"
    end,
    toggle_playback = function()
      awful.spawn("playerctl play-pause", false)
      gears.timer.start_new(1, function()
        this.__private.update()
        return false
      end)
    end,
    next_track = function()
      awful.spawn("playerctl next", false)
      gears.timer.start_new(1, function()
        this.__private.update()
        return false
      end)
    end,
    prev_track = function()
      awful.spawn("playerctl previous", false)
      gears.timer.start_new(1, function()
        this.__private.update()
        return false
      end)
    end
  }

  this.__construct = function()
    this.__public.value.visible = false
    this.__public.icon.visible = false
    
    gears.timer.start_new(2, function()
      this.__private.update()
      return false
    end)
    
    gears.timer.start_new(5, function()
      this.__private.update()
      return true
    end)
  end

  return this
end

MediaWidget = createClass(MediaWidget_prototype)
```

- [ ] **Step 2: Commit**

```bash
git add user_config/awesome/modules/widgets/media_widget.lua
git commit -m "feat: add MPRIS media controller widget"
```

---

### Task 3: Create clipboard_widget.lua

**Files:**
- Create: `user_config/awesome/modules/widgets/clipboard_widget.lua`

- [ ] **Step 1: Create clipboard_widget.lua**

```lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

ClipboardWidget_prototype = function()
  local this = {}

  this.__public_static = {
    config_path = gears.filesystem.get_configuration_dir()
  }

  this.__public = {
    name = "ClipboardWidget",
    icon = wibox.widget.imagebox(),
    on_container_created = function(container, panel_position)
      local is_top_panel_position = panel_position == "top"
      local is_bottom_panel_position = panel_position == "bottom"
      
      local offset_y = dpi(is_top_panel_position and 8 or is_bottom_panel_position and -8 or 0)
      
      this.__private.clipboard_popup.offset = {
        y = offset_y,
      }
      
      container:buttons(
        awful.util.table.join(
          awful.button({}, 1, function()
            this.__private.rebuild_popup()
            this.__private.clipboard_popup.visible = not this.__private.clipboard_popup.visible
          end)
        )
      )
    end,
    hide_dropdown = function()
      this.__private.clipboard_popup.visible = false
    end
  }

  this.__private = {
    clipboard_popup = nil,
    rebuild_popup = function()
      local rows = { layout = wibox.layout.fixed.vertical }
      
      awful.spawn.easy_async("clipman list --max-items=10", function(output)
        local items = {}
        for line in output:gmatch("[^\n]+") do
          if line:match("^%d+%.") then
            table.insert(items, line:sub(4))
          end
        end
        
        for i, item in ipairs(items) do
          local display_text = item:sub(1, 50) .. (item:len() > 50 and "..." or "")
          
          local row = wibox.widget {
            {
              {
                {
                  text = display_text,
                  align = "left",
                  widget = wibox.widget.textbox
                },
                margins = dpi(8),
                layout = wibox.container.margin
              },
              widget = wibox.container.background
            }
          }
          
          row:connect_signal("mouse::enter", function(c)
            c:set_bg(beautiful.menu_bg_focus)
            c:set_fg(beautiful.fg_focus)
          end)
          
          row:connect_signal("mouse::leave", function(c)
            c:set_bg(gears.color.transparent)
            c:set_fg(beautiful.fg_normal)
          end)
          
          row:connect_signal("button::press", function()
            awful.spawn("clipman pick --tool=none", false)
            this.__private.clipboard_popup.visible = false
          end)
          
          table.insert(rows, row)
        end
        
        if #items == 0 then
          local empty_row = wibox.widget {
            {
              text = "Clipboard empty",
              align = "center",
              widget = wibox.widget.textbox
            },
            margins = dpi(16),
            layout = wibox.container.margin
          }
          table.insert(rows, empty_row)
        end
        
        this.__private.clipboard_popup:setup(rows)
      end)
    end
  }

  this.__construct = function()
    this.__public.icon.image = gears.color.recolor_image(
      this.__public_static.config_path .. "/themes/relz/icons/widgets/clipboard.svg",
      beautiful.text_color
    )
    
    this.__private.clipboard_popup = awful.popup {
      widget = {},
      type = "dropdown_menu",
      shape = gears.shape.rounded_rect,
      visible = false,
      ontop = true,
      bg = beautiful.bg_normal .. "99",
      max_width = dpi(400),
      max_height = dpi(300),
    }
    
    root.buttons(gears.table.join(root.buttons(),
      awful.button({}, 1, this.__public.hide_dropdown),
      awful.button({}, 2, this.__public.hide_dropdown),
      awful.button({}, 3, this.__public.hide_dropdown)
    ))
  end

  return this
end

ClipboardWidget = createClass(ClipboardWidget_prototype)
```

- [ ] **Step 2: Commit**

```bash
git add user_config/awesome/modules/widgets/clipboard_widget.lua
git commit -m "feat: add clipboard history widget"
```

---

### Task 4: Enhance existing widgets with glow effects

**Files:**
- Modify: `user_config/awesome/modules/widgets/cpu_widget.lua`
- Modify: `user_config/awesome/modules/widgets/volume_widget.lua`
- Modify: `user_config/awesome/modules/widgets/network_widget.lua`
- Modify: `user_config/awesome/modules/widgets/bluetooth_widget.lua`
- Modify: `user_config/awesome/modules/widgets/battery_widget.lua`
- Modify: `user_config/awesome/modules/widgets/calendar_widget.lua`
- Modify: `user_config/awesome/modules/widgets/clock_widget.lua`

- [ ] **Step 1: Add glow effect to cpu_widget.lua**

In `config/panels.lua`, widgets are wrapped in containers. The glow effect is applied via the theme. For now, ensure each widget's icon can receive hover effects.

Add to the end of `CpuWidget_prototype`, inside `__construct`:

```lua
    this.__public.icon:connect_signal("mouse::enter", function()
      this.__public.icon.bg = beautiful.glow_cyan .. "22"
    end)
    
    this.__public.icon:connect_signal("mouse::leave", function()
      this.__public.icon.bg = gears.color.transparent
    end)
```

- [ ] **Step 2: Apply same pattern to volume_widget.lua**

Add the same hover effect code to `VolumeWidget_prototype.__construct`.

- [ ] **Step 3: Apply same pattern to network_widget.lua**

Add the same hover effect code to `NetworkWidget_prototype.__construct`.

- [ ] **Step 4: Apply same pattern to bluetooth_widget.lua**

Add the same hover effect code to `BluetoothWidget_prototype.__construct`.

- [ ] **Step 5: Apply same pattern to battery_widget.lua**

Add the same hover effect code to `BatteryWidget_prototype.__construct`.

- [ ] **Step 6: Apply same pattern to calendar_widget.lua**

Add the same hover effect code to `CalendarWidget_prototype.__construct`.

- [ ] **Step 7: Apply same pattern to clock_widget.lua**

Add the same hover effect code to `ClockWidget_prototype.__construct`.

- [ ] **Step 8: Commit**

```bash
git add user_config/awesome/modules/widgets/*_widget.lua
git commit -m "feat: add hover glow effects to all widgets"
```

---

### Task 5: Update panel.lua for floating island design

**Files:**
- Modify: `user_config/awesome/modules/panel.lua`
- Modify: `config/panels.lua`

- [ ] **Step 1: Update Panel prototype in panel.lua**

Modify `user_config/awesome/modules/panel.lua` to add floating properties:

```lua
this.__public = {
  position = "top",
  thickness = 24,
  opacity = 0.9,
  floating = true,  -- NEW
  margin = dpi(4),  -- NEW
  tags = Tags(),
  tasks = Tasks(),
  widgets = {},
  launcher = wibox.widget.base
}
```

- [ ] **Step 2: Update config/panels.lua to apply floating style**

Modify the panel creation to add rounded corners and margin:

```lua
local screen_0_panel = Panel()
screen_0_panel.position = "top"
screen_0_panel.floating = true
screen_0_panel.margin = dpi(4)

if vars.current_os == "Linux" then
  screen_0_panel.thickness = 32
  screen_0_panel.opacity = 0.9
end
```

- [ ] **Step 3: Add systray to panel**

In `config/panels.lua`, add systray to the FreeBSD widgets list (and Linux if desired):

```lua
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
    wibox.widget.systray(),  -- ADD THIS
  }
end
```

- [ ] **Step 4: Commit**

```bash
git add user_config/awesome/modules/panel.lua user_config/awesome/config/panels.lua
git commit -m "feat: make panel floating with rounded corners and systray"
```

---

### Task 6: Update config/widgets.lua to include new widgets

**Files:**
- Modify: `user_config/awesome/config/widgets.lua`

- [ ] **Step 1: Add media and clipboard widgets**

Add to the end of the widget instantiation list:

```lua
local media_widget = MediaWidget()
local clipboard_widget = ClipboardWidget()
```

Add to the return table:

```lua
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
  media_widget = media_widget,  -- NEW
  clipboard_widget = clipboard_widget,  -- NEW
}
```

- [ ] **Step 2: Commit**

```bash
git add user_config/awesome/config/widgets.lua
git commit -m "feat: instantiate media and clipboard widgets"
```

---

### Task 7: Update config/panels.lua widget order

**Files:**
- Modify: `user_config/awesome/config/panels.lua`

- [ ] **Step 1: Reorder widgets**

Update the Linux widgets list to include new widgets in order:

```lua
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
```

- [ ] **Step 2: Commit**

```bash
git add user_config/awesome/config/panels.lua
git commit -m "feat: reorder widgets and add systray"
```

---

### Task 8: Update rc.lua to require new widgets

**Files:**
- Modify: `user_config/awesome/rc.lua`

- [ ] **Step 1: Add requires for new widgets**

Add after the existing widget requires:

```lua
require("modules.widgets.media_widget")
require("modules.widgets.clipboard_widget")
```

- [ ] **Step 2: Commit**

```bash
git add user_config/awesome/rc.lua
git commit -m "feat: require new media and clipboard widget modules"
```

---

### Task 9: Verify and test

**Files:** All modified files

- [ ] **Step 1: Run Lua syntax check**

```bash
cd /home/alejandro/dotfiles/user_config/awesome
luac -p rc.lua && echo "OK" || echo "FAIL"
luac -p modules/widgets/media_widget.lua && echo "OK" || echo "FAIL"
luac -p modules/widgets/clipboard_widget.lua && echo "OK" || echo "FAIL"
```

- [ ] **Step 2: Verify playerctl is installed**

```bash
which playerctl || echo "playerctl not found - install with: sudo apt install playerctl"
```

- [ ] **Step 3: Verify clipman is installed**

```bash
which clipman || echo "clipman not found - should be installed via xfce4-clipman"
```

- [ ] **Step 4: Fix any syntax errors**

If any files fail syntax check, fix them and re-run.

- [ ] **Step 5: Commit fixes if any**

```bash
git add -A
git commit -m "fix: resolve syntax errors in panel enhancements"
```

---

### Task 10: Add missing icons

**Files:**
- Create: `user_config/awesome/themes/relz/icons/widgets/media_playing.svg`
- Create: `user_config/awesome/themes/relz/icons/widgets/media_paused.svg`
- Create: `user_config/awesome/themes/relz/icons/widgets/clipboard.svg`

- [ ] **Step 1: Create media_playing.svg**

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <polygon points="10,8 16,12 10,16" fill="currentColor"/>
</svg>
```

- [ ] **Step 2: Create media_paused.svg**

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="10" fill="none" stroke="currentColor" stroke-width="2"/>
  <rect x="9" y="8" width="2" height="8" fill="currentColor"/>
  <rect x="13" y="8" width="2" height="8" fill="currentColor"/>
</svg>
```

- [ ] **Step 3: Create clipboard.svg**

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
  <rect x="6" y="4" width="12" height="16" rx="2" fill="none" stroke="currentColor" stroke-width="2"/>
  <rect x="9" y="2" width="6" height="4" rx="1" fill="currentColor"/>
  <line x1="9" y1="10" x2="15" y2="10" stroke="currentColor" stroke-width="2"/>
  <line x1="9" y1="14" x2="15" y2="14" stroke="currentColor" stroke-width="2"/>
  <line x1="9" y1="18" x2="13" y2="18" stroke="currentColor" stroke-width="2"/>
</svg>
```

- [ ] **Step 4: Commit**

```bash
git add user_config/awesome/themes/relz/icons/widgets/*.svg
git commit -m "feat: add media and clipboard widget icons"
```
