return {
  {
    "gbprod/substitute.nvim",
    event = "BufRead",
    config = function()
      -- Setup plugin
      require("substitute").setup()

      -- Setup keybinds
      local m = require("conf.utils.map")
      m.nnoremap(
        "R",
        "<cmd>lua require('substitute').operator()<cr>",
        "Substitute"
      )
      m.nnoremap(
        "RR",
        "<cmd>lua require('substitute').line()<cr>",
        "Substitute line"
      )
      m.xnoremap(
        "R",
        "<cmd>lua require('substitute').visual()<cr>",
        "Substitute"
      )
    end,
  },
}
