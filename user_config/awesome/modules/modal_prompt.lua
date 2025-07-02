local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local gfs = require("gears.filesystem")
local inspect = require("modules/inspect")
local beautiful = require("beautiful")
--local naughty = require("naughty")


modal_eval_box = nil
keygrabber_eval = nil

local prompt_widget = wibox.widget {
    --text = "",
    widget = wibox.widget.textbox,
    --widget = awful.widget.prompt,
    align = "left",
    valign = "top"
}

local result_widget = wibox.widget {
    text = "",
    widget = wibox.widget.textbox,
    align = "left",
    valign = "top"
}

local result_controller = wibox.widget {
    layout = wibox.container.scroll.vertical,
    max_size = 10000,
    step_function = wibox.container.scroll.step_functions
                   .waiting_nonlinear_back_and_forth,
    speed = 1,
    result_widget
}

local ratio_layout = wibox.widget {
    spacing_widget = {
      shape = gears.shape.powerline,
      widget = wibox.widget.separator
    },
    spacing = 10,
      {
      widget = wibox.container.margin,
      margins = 10,
      prompt_widget,
    },
    {
      widget = wibox.container.margin,
      margins = 10,
      result_controller
    },
    layout = wibox.layout.ratio.vertical,
  }

local awm_lua_repl = function(input)
      result_widget.text = ""
      local result
      local ok, err = pcall(function()
        local f = assert(load("return " .. input))
        result = f()
      end)

      if ok then
         result_widget.text = type(result) == "table" and inspect(result) or tostring(result)
         --result_widget.text = type(result_controller) == "table" and inspect(result_controller) or tostring(result_controller)
         --result_controller:vertical(50)
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
      run_prompt(prompt_widget, result_widget)
  end

local write_to_file = function(file_name, contents)
  local file_path = gfs.get_configuration_dir() .. file_name
  local fd = io.open(file_path, "w")
  io.output(fd)
  io.write(contents)
  io.close()
end

run_prompt = function(prompt_widget,  result_widget)
    awful.prompt.run {
    prompt        = "AWRepl> ",
    history_path  = gfs.get_cache_dir() .. '/awesome/repl/history',
    history_max   = 500,
    textbox       = prompt_widget,
    font = beautiful.font or "Monospace 12",
    bg = beautiful.bg_normal,
    fg = beautiful.fg_normal,
    exe_callback = awm_lua_repl,
    done_callback = function()
      -- do nothing, avoid close widget
    end,
    hooks =  {
      {
        {"Control"},"Tab",
        function()
          --result_controller:reset_scrolling()
          --beautiful.notification_max_height = 5000
          --beautiful.notification_max_width = 500
          --naughty.notify({text=inspect(result_controller),height=1000, width=500, timeout=0})
          write_to_file("repl_debug.0", inspect(result_controller))
          write_to_file("repl_debug.1", inspect(result_widget))
          write_to_file("repl_output.0", tostring(result_widget.text))
          return true
        end
      },
      {
        {},"Escape",
        function()
          modal_eval_box.visible = false
          modal_eval_box = nil
        end
      },
    }
  }
end

function toggle_repl_modal()
  if modal_eval_box and  modal_eval_box.visible then
    modal_eval_box.visible = false
    modal_eval_box = nil
    keygrabber_eval = nil
  else
    repl_modal()
  end
end

repl_modal = function()
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

  result_widget.text = ""

  local screen = awful.screen.focused()
  local width = 1000
  local height = 500

  ratio_layout:set_ratio(1, 0.1)
  ratio_layout:set_ratio(3, 0.9)

  modal_eval_box = wibox({
    screen = screen,
    type = "normal",
    width = width,
    height = height,
    ontop = true,
    visible = true,
    bg = beautiful.bg_normal or "#222222",
    shape = gears.shape.rounded_rect,
    layout = wibox.layout.ratio.vertical,
    --border_width = 4,
    input_passthrough = false,
    widget = ratio_layout
  })

  modal_eval_box.x = (screen.geometry.width - width) / 2
  modal_eval_box.y = (screen.geometry.height - height) / 2

  -- keygrabber_eval = awful.keygrabber {
  --   start_callback = function() end,
  --   stop_callback = function()
  --      if modal_eval_box then
  --       modal_eval_box.visible = false
  --       modal_eval_box = nil
  --      end
  --     keygrabber_eval = nil
  --   end,
  --   export_keybindings = true,
  --   stop_event = "release",
  --   keybindings = {
  --     { {}, "Escape", function()
  --         if keygrabber_eval then
  --           keygrabber_eval:stop()
  --         end
  --     end },
  --   }
  -- }

  -- keygrabber_eval:start()

  run_prompt(prompt_widget, result_widget)

end
