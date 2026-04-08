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
local media_widget = MediaWidget()
local clipboard_widget = ClipboardWidget()

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
	media_widget = media_widget,
	clipboard_widget = clipboard_widget,
}
