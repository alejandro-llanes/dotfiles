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