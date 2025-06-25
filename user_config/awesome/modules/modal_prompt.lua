local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")


modal_eval_box = nil
keygrabber_eval = nil

function toggle_prompt_modal()
  if modal_eval_box and modal_eval_box.visible then
    -- Hide the modal
    modal_eval_box.visible = false
    modal_eval_box = nil
    if keygrabber_eval then
      keygrabber_eval:stop()
      keygrabber_eval = nil
    end
    return
  end

  local screen = awful.screen.focused()
  --local width = 500
  --local height = 150
  local width = 1000
  local height = 500

  local result_widget = wibox.widget {
    text = "",
    widget = wibox.widget.textbox,
    align = "left",
    valign = "top"
  }

  local prompt_widget = awful.widget.prompt {
    prompt = "Run Lua: ",
    font = beautiful.font or "Monospace 12",
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal
  }

  modal_eval_box = wibox({
    screen = screen,
    width = width,
    height = height,
    ontop = true,
    visible = true,
    bg = beautiful.bg_normal or "#222222",
    shape = gears.shape.rounded_rect
  })

  modal_eval_box:setup {
    layout = wibox.layout.fixed.vertical,
    {
      widget = wibox.container.margin,
      margins = 10,
      prompt_widget
    },
    {
      widget = wibox.container.margin,
      margins = 10,
      result_widget
    }
  }

  modal_eval_box.x = (screen.geometry.width - width) / 2
  modal_eval_box.y = (screen.geometry.height - height) / 2

  keygrabber_eval = awful.keygrabber {
    start_callback = function() end,
    stop_callback = function()
       if modal_eval_box then
        modal_eval_box.visible = false
        modal_eval_box = nil
       end
      keygrabber_eval = nil
    end,
    export_keybindings = true,
    stop_event = "release",
    keybindings = {
      { {}, "Escape", function()
          if keygrabber_eval then
            keygrabber_eval:stop()
          end
      end },
    }
  }

  keygrabber_eval:start()

  awful.prompt.run {
    prompt       = "Lua> ",
    textbox      = prompt_widget.widget,
    exe_callback = function(input)
      local result
      local ok, err = pcall(function()
        local f = assert(load("return " .. input))
        result = f()
      end)

      if ok then
        result_widget.text = "=> " .. tostring(result)
      else
        local ok2, err2 = pcall(function()
          local f = assert(load(input))
          result = f()
        end)
        if ok2 then
          result_widget.text = "=> (executed)"
        else
          result_widget.text = "Error: " .. (err2 or "invalid input")
        end
      end
    end,
    done_callback = function() end
  }
end
