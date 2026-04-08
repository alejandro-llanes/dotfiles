# Enhanced AwesomeWM Panel Design

## Goal

Redesign the AwesomeWM panel to be more visually appealing ("eye candy") and useful, combining modern minimal aesthetics with cyberpunk glow effects, and adding new functional widgets.

## Visual Style

**Modern minimal base:**
- Floating bar design with 8px rounded corners
- Subtle blur background (requires picom compositor)
- Clean typography with consistent spacing
- High contrast text on muted background

**Cyberpunk glow accents:**
- Neon cyan (`#00E4C5`) glow on active/focused elements
- Purple (`#9D7AD4`) as secondary accent color
- Subtle outer glow on hover (2-3px blur radius)
- Pulsing animation for urgent notifications
- Gradient borders on widgets (1px, cyan to purple)

## Layout Structure

```
┌────────────────────────────────────────────────────────────────────┐
│  [Launcher]  [1][2][3]  │  [App 1] [App 2] [App 3]  │  Widgets  │  [Systray]  │
└────────────────────────────────────────────────────────────────────┘
```

**Sections (left to right):**
1. **Left:** Launcher icon + tag buttons (workspaces)
2. **Center:** Tasklist (active windows)
3. **Right - Widgets:** Network, Bluetooth, Volume, Media, Clipboard, Calendar/Time, Battery
4. **Far Right:** Systray (for nm-applet, blueman-applet, pasystray)

## Widget Inventory

### Existing Widgets (Enhanced)

| Widget | File | Enhancements |
|--------|------|--------------|
| Launcher | `modules/widgets/launch_widget.lua` | Glow effect on hover, smoother icon |
| Tags | `modules/tags.lua` | Glow on active, pulse animation on urgent |
| Tasklist | `modules/tasks.lua` | Glow on focus, better typography |
| Network | `modules/widgets/network_widget.lua` | Glow, upload/download sparkline |
| Bluetooth | `modules/widgets/bluetooth_widget.lua` | Glow, device battery in popup |
| Volume | `modules/widgets/volume_widget.lua` | Glow, enhanced popup UI |
| Battery | `modules/widgets/battery_widget.lua` | Glow, time remaining display |
| Calendar/Clock | `modules/widgets/calendar_widget.lua`, `modules/widgets/clock_widget.lua` | Moon phase, sunrise/sunset, next event |

### New Widgets

| Widget | File | Description |
|--------|------|-------------|
| Media Controller | `modules/widgets/media_widget.lua` | MPRIS player control (Spotify, etc.) - album art, track title, play/pause/skip |
| Clipboard | `modules/widgets/clipboard_widget.lua` | Clipboard history via clipman - searchable, pinned items, recent entries |

## Color Palette

```lua
-- Base colors (from current theme)
bg_normal      = "#1e293d"    -- dark blue-gray
fg_normal      = "#f4feff"    -- light cyan-white

-- Glow accent colors
glow_cyan      = "#00E4C5"    -- primary glow (existing active color)
glow_purple    = "#9D7AD4"    -- secondary glow accent
glow_danger    = "#db5853"    -- urgent/error states

-- Gradient definition (for borders)
border_gradient = {
    type = "linear",
    from = {0, 0},
    to = {1, 0},
    stops = {{0, glow_cyan}, {1, glow_purple}}
}
```

## Animations & Effects

### Hover Effects
- Widget icons: Glow + scale to 1.05x
- Tag buttons: Glow intensifies, background brightens
- Tasklist items: Subtle glow border

### State Indicators
- Active tag: Solid cyan glow border
- Urgent tag: Pulsing red glow (0.8s cycle)
- Focused task: Cyan glow underline

### Popup Transitions
- Volume dropdown: Slide down + fade in (150ms)
- Calendar popup: Slide up + fade in (150ms)
- Clipboard history: Slide down + fade in (150ms)
- Media controller: Fade in (100ms)

### Media Widget Animation
- Album art: Slow rotation when playing (360°/30s)
- Pause: Rotation stops

## Technical Implementation

### Theme Changes (`themes/relz/theme.lua`)

Add new theme properties:
```lua
theme.glow_cyan = "#00E4C5"
theme.glow_purple = "#9D7AD4"
theme.glow_danger = "#db5853"
theme.glow_blur = dpi(3)
theme.glow_spread = dpi(2)
theme.panel_border_radius = dpi(8)
theme.widget_spacing = dpi(4)
theme.animation_duration_fast = 0.1  -- seconds
theme.animation_duration_normal = 0.15
```

### Panel Changes (`config/panels.lua`)

- Change from edge-attached to floating bar
- Add background shape with rounded corners
- Apply backdrop blur (via picom)
- Reorganize widget order
- Add systray widget

### New Widget Structure

Each new widget follows the existing class pattern:
```lua
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

MediaWidget_prototype = function()
  local this = {}
  -- ... class definition following existing patterns
end
MediaWidget = createClass(MediaWidget_prototype)
```

### Dependencies

- **MPRIS support:** Uses `playerctl` or D-Bus to control media players
- **Clipboard:** Uses existing `xfce4-clipman` (already in autostart)
- **Moon phase:** Calculate from date, no external dependency
- **Sunrise/sunset:** Already implemented in utils.lua (`get_sunrise_time_minutes`, `get_sunset_time_minutes`)

## Widget Order in Panel

Right section, left to right:
1. Network widget
2. Bluetooth widget
3. Volume widget
4. Media controller widget (NEW)
5. Clipboard widget (NEW)
6. Calendar/Time widgets (combined)
7. Battery widget
8. Systray

## Picom Configuration (Optional)

For blur effect, add to picom.conf:
```conf
blur = {
    method = "dual_kawase";
    strength = 3;
    background = false;
    background_frame = false;
    background_excluded = [];
};
```

## Success Criteria

- Panel floats with visible rounded corners
- Glow effects visible on hover and active states
- New media widget shows current track and controls playback
- Clipboard widget shows history and allows paste
- All animations smooth (no stuttering)
- Systray icons display correctly
- No breaking changes to existing widget functionality
