local M = {}

M.def = {
  {
    "folke/which-key.nvim",
  },
}

M.config = function()
  local wk = require("which-key")
  wk.setup({
    plugins = {
      registers = false,
      spelling = true, -- Spelling hints with z=
      presets = {
        operators = false,
        motions = false,
        text_objects = false,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    window = {
      border = "rounded", -- none, single, double, shadow
    },
    key_labels = {
      ["<space>"] = "SPC",
      ["<cr>"] = "RET",
      ["<tab>"] = "TAB",
    },
  })
end

return M
