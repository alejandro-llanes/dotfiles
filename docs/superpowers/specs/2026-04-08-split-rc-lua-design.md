# Split rc.lua into topic-based config files

## Goal

Make `rc.lua` (927 lines) more readable by splitting configurations by topic into separate Lua files, with `rc.lua` acting only as an orchestrator.

## Approach

**Topic-based flat files** — each config file returns a table of exports, `rc.lua` requires each and wires dependencies explicitly.

## Directory structure

```
awesome/
  rc.lua                    (~50 lines: requires + wiring)
  config/
    variables.lua           App commands, wallpaper, OS vars, numpad codes
    widgets.lua             Widget instantiation
    panels.lua              Panel layout per OS
    screens.lua             Screen setup, xrandr, multi-monitor
    keys.lua                Global keys, client keys, tag key loops
    rules.lua               Client rules, titlebars
    signals.lua             Client signals (icon, focus, urgent)
    initialization.lua      Redshift, geolocation, network interfaces
    autostart.lua           OS-specific startup commands
```

## Dependency graph

```
variables.lua  → (no config deps, uses utils/helper)
widgets.lua    → variables.lua
panels.lua     → widgets.lua, variables.lua
screens.lua    → panels.lua, variables.lua
keys.lua       → variables.lua, widgets.lua
rules.lua      → keys.lua
signals.lua    → widgets.lua, keys.lua
initialization → variables.lua, widgets.lua
autostart.lua  → variables.lua
```

## How each file works

Each file returns a table of its exports. `rc.lua` requires each, then calls setup functions and registers keys/rules/signals.

### config/variables.lua

- App commands (terminal, browser, file_manager, etc.)
- wallpaper path
- OS detection result and OS-specific interface names
- numpad key codes
- geolocation defaults

Returns a table with all these values.

### config/widgets.lua

Imports from `config.variables` for command strings.
Instantiates all widgets (CpuWidget, BrightnessWidget, etc.).
Returns a table of widget instances.

### config/panels.lua

Imports from `config.widgets` and `config.variables`.
Defines `task_left_button_press_action` and panel layouts per OS.
Returns a table of panel instances.

### config/screens.lua

Imports from `config.panels` and `config.variables`.
Defines `update_screens` and screen signal handlers.
Exports a `setup(screens_manager, vars, panels)` function.

### config/keys.lua

Imports from `config.variables` and `config.widgets`.
Defines `set_brightness`, `set_volume`, `mute`, `toggle_panel`, `swap_clients_between_tags`.
Defines `global_keys`, `client_keys`, and tag key loops.
Returns `{ global_keys, client_keys }`.

### config/rules.lua

Imports `client_keys` from `config.keys`.
Defines `awful.rules.rules` table and `client_buttons`.
Defines `hide_dropdowns` (references widget instances).
Returns `{ client_rules, client_buttons, hide_dropdowns }`.

### config/signals.lua

Imports from `config.widgets` and `config.keys`.
Registers client signals: property::urgent, manage (icon fallback), manage (mouse enter focus), request::titlebars.
Exports a `register(widgets, keys)` function.

### config/initialization.lua

Imports from `config.variables` and `config.widgets`.
Handles redshift config dir creation, geolocation resolution, network interface detection.
Exports a `run(vars, widgets)` function.

### config/autostart.lua

Imports from `config.variables`.
Runs OS-specific startup commands via `executer`.
Exports a `run(vars)` function.

## rc.lua after refactoring

Only contains:
- Top-level `require` calls for modules (utils, helper, icons, etc.)
- `require("awful.autofocus")`
- Standard library requires (awful, gears, etc.)
- `require("modules.error_handling")` and `screens_manager` require
- `beautiful.init(...)`
- Config file requires: variables, widgets, panels, screens, keys, rules, signals, initialization, autostart
- `root.keys(keys.global_keys)`
- `awful.rules.rules = rules.client_rules`
- Setup/register calls: `screens.setup(...)`, `signals.register(...)`, `init.run(...)`, `autostart.run(...)`

## Key decisions

1. `swap_clients_between_tags` lives in `keys.lua` since it's only used by client key bindings
2. `update_screens` screen logic moves to `screens.lua` as a `setup()` function
3. OS-conditional interface vars (wired/wireless) are fixed: currently declared `local` inside `if` blocks (making them inaccessible outside), they will be properly scoped in `variables.lua`
4. Menu keys and hotkeys popup move to `keys.lua`
5. The `client icon fallback` signal moves to `signals.lua`
6. Circular dependency avoidance: `signals.lua` and `rules.lua` receive widget references at registration time rather than requiring them at module load time where it would create cycles

## What stays in rc.lua

Only: top-level requires, `beautiful.init`, wiring calls, `root.keys()`, `awful.rules.rules` assignment. No logic or configuration definitions.