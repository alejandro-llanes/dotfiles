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
      local ok, err = pcall(function()
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
      end)
      if not ok then
        require("naughty").notify({ title = "MediaWidget Error", text = err, timeout = 5 })
      end
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
