-- in lua/user/mappings.lua
return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
          n = {
            ["<D-Up>"]    = { "<C-w>k", desc = "Move to window above" },
            ["<D-Down>"]  = { "<C-w>j", desc = "Move to window below" },
            ["<D-Left>"]  = { "<C-w>h", desc = "Move to window left" },
            ["<D-Right>"] = { "<C-w>l", desc = "Move to window right" },
        },
      },
    },
  },
}

