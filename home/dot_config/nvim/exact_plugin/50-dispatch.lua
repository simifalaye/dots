local lazy = require("utils.lazy")

lazy.later(function()
  vim.pack.add({
    { src = "https://github.com/tpope/vim-dispatch.git" },
  })
end)
