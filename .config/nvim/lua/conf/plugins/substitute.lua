local M = {}

M.def = {
  {
    "gbprod/substitute.nvim",
    event = "BufRead",
  },
}

M.config = function()
  -- Setup plugin
  require("substitute").setup()

  -- Setup keybinds
  local m = require("conf.utils.map")
  m.nnoremap("s", "<cmd>lua require('substitute').operator()<cr>", "Substitute")
  m.nnoremap(
    "ss",
    "<cmd>lua require('substitute').line()<cr>",
    "Substitute line"
  )
  m.nnoremap("S", "<cmd>lua require('substitute').eol()<cr>", "Substitute eol")
  m.nnoremap(
    "sx",
    "<cmd>lua require('substitute.exchange').operator()<cr>",
    "Exchange"
  )
  m.nnoremap(
    "sxx",
    "<cmd>lua require('substitute.exchange').line()<cr>",
    "Exchange Line"
  )
  m.nnoremap(
    "sxc",
    "<cmd>lua require('substitute.exchange').cancel()<cr>",
    "Exchange cancel"
  )
  m.xnoremap("s", "<cmd>lua require('substitute').visual()<cr>", "Substitute")
  m.xnoremap(
    "X",
    "<cmd>lua require('substitute.exchange').visual()<cr>",
    "Exchange"
  )
end

return M
