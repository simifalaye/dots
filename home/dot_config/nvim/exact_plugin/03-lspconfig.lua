local lazy = require("utils.lazy")

lazy.now(function()
  vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/b0o/schemastore.nvim" },
  })
end)
