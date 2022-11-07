local M = {}

M.def = {
  {
    "williamboman/mason.nvim",
    requires = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },
}

M.config = function()
  local utils = require("conf.utils")
  local mason_dir = utils.join_paths(vim.fn.stdpath("data"), "mason")

  -- Setup mason
  local mason = require("mason")
  mason.setup({
    install_root_dir = mason_dir,
    max_concurrent_installers = 10,
  })
  -- Setup auto-installer
  local mason_installer = require("mason-tool-installer")
  mason_installer.setup({
    ensure_installed = {
      -- Language servers
      "bash-language-server",
      "lua-language-server",
      "vim-language-server",
      -- Linters
      "shellcheck",
      -- Formatters
      "stylua",
    },
    auto_update = false,
    run_on_start = true,
  })
  -- Setup lsp config defaults
  require("mason-lspconfig").setup()
end

return M
