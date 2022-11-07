local M = {}

M.def = {
  {
    "danymat/neogen",
    requires = {
      "nvim-treesitter/nvim-treesitter",
    },
    after = "nvim-treesitter",
  },
}

M.config = function()
  -- Setup plugin
  require("neogen").setup({
    enabled = true,
  })

  -- Setup keybinds
  local m = require("conf.utils.map")
  m.group("<leader>a", "+annotate")
  m.nnoremap("<leader>ac", function()
    require("neogen").generate({ type = "class" })
  end, "Class annotation")
  m.nnoremap("<leader>af", function()
    require("neogen").generate({})
  end, "Func annotation")
  m.nnoremap("<leader>at", function()
    require("neogen").generate({ type = "type" })
  end, "Type annotation")
end

return M
