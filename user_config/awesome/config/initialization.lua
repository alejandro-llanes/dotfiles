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
