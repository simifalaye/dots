return {
  {
    "danymat/neogen",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "Neogen" },
    init = function()
      local m = require("utils.map")
      m.nnoremap("<leader>a", "<cmd>Neogen<CR>", "Generate (a)nnotation")
    end,
    opts = { snippet_engine = "luasnip" },
  },
}
