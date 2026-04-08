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
