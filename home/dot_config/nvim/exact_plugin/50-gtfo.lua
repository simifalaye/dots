local lazy = require("utils.lazy")

lazy.later(function()
  vim.pack.add({
    { src = "https://github.com/justinmk/vim-gtfo.git" },
  })
end)
