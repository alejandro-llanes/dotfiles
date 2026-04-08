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
