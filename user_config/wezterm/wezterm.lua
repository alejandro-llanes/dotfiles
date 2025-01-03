
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

--local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
--local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

config.color_scheme = "Tokyo Night Moon"
config.window_background_opacity = 0.4
config.default_prog = { "/usr/bin/fish", "-l" }
--config.window_background_image = wezterm.home_dir .. "/Pictures/synthwave2.jpg"
--config.enable_tab_bar = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

--config.tab_bar_style = {
--  active_tab_left = wezterm.format {
--    { Background = { Color = '#0b0022' } },
--    { Foreground = { Color = '#2b2042' } },
--    { Text = SOLID_LEFT_ARROW },
--  },
--  active_tab_right = wezterm.format {
--    { Background = { Color = '#0b0022' } },
--    { Foreground = { Color = '#2b2042' } },
--    { Text = SOLID_RIGHT_ARROW },
--  },
--  inactive_tab_left = wezterm.format {
--    { Background = { Color = '#0b0022' } },
--    { Foreground = { Color = '#1b1032' } },
--    { Text = SOLID_LEFT_ARROW },
--  },
--  inactive_tab_right = wezterm.format {
--    { Background = { Color = '#0b0022' } },
--    { Foreground = { Color = '#1b1032' } },
--    { Text = SOLID_RIGHT_ARROW },
--  },
--}

return config
