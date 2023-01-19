return {
  {
    "ojroques/nvim-osc52",
    keys = {
      { "<leader>y", mode = { "n", "x" } },
    },
    config = function()
      local m = require("utils.map")
      m.nnoremap(
        "<leader>y",
        require("osc52").copy_operator,
        "System yank",
        { expr = true }
      )
      m.nmap("<leader>yy", "<leader>y_", "System yank line")
      m.xmap("<leader>y", require("osc52").copy_visual, "System yank visual")
    end,
  },
}
