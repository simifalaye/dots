return {
  {
    "danymat/neogen",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "Neogen" },
    init = function()
      local m = require("conf.utils.map")
      m.nnoremap("<leader>a", "<cmd>Neogen<CR>", "Annotate doc")
    end,
    config = { snippet_engine = "luasnip" },
  },
}