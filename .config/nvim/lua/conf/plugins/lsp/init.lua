local mod = (...):gsub("%.init$", "")
local fmt = string.format

local M = {}

M.def = {
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    after = "mason.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
      "jose-elias-alvarez/null-ls.nvim",
      "folke/neodev.nvim",
    },
  },
}

M.setup = function()
  -- Setup global keymaps
  require(fmt("%s.keymaps", mod))(nil, nil)
end

M.config = function()
  local log = require("conf.utils.log")
  local autorequire = require("conf.utils.autorequire")
  local prequire = require("conf.utils.prequire")
  local lspconfig = require("lspconfig")
  require(fmt("%s.diagnostics", mod))()

  -- IMPORTANT: make sure to setup lua-dev BEFORE lspconfig
  require("neodev").setup({
    override = function(root_dir, library)
      local utils = require("conf.utils")
      -- Enable lua-dev for chezmoi
      if require("neodev.util").has_file(root_dir, utils.dotpath()) then
        library.enabled = true
        library.plugins = true
      end
    end,
  })

  -- Default server options
  local options = {
    on_attach = function(client, bufnr)
      require(fmt("%s.formatting", mod))(client, bufnr)
      require(fmt("%s.autocmds", mod))(client, bufnr)
      require(fmt("%s.keymaps", mod))(client, bufnr)
    end,
    capabilities = require(fmt("%s.capabilities", mod))(),
    flags = {
      debounce_text_changes = 150,
    },
  }

  -- Configure servers
  local mason_lsp = prequire("mason-lspconfig")
  if mason_lsp then
    -- Configure mason-installed servers if mason is available
    log.debug("Configuring lsp servers with mason")
    local mason_handlers = {
      function(name) -- default handler
        -- Check for custom provider
        local opts = prequire(fmt("%s.providers.%s", mod, name))
        local config = vim.tbl_deep_extend("force", options, opts or {})
        log.debug(fmt("Configuring server '%s', with config: %s", name, config))
        lspconfig[name].setup(config)
      end,
    }
    mason_lsp.setup_handlers(mason_handlers)
  else
    -- Else configure only the servers that have a provider config file
    log.debug("Configuring lsp servers manually")
    for _, provider in
      pairs(autorequire.getmodlist(fmt("%s.providers", mod), {}))
    do
      local opts = prequire(provider)
      local config = vim.tbl_deep_extend("force", options, opts or {})
      local prov_tbl = vim.fn.split(provider, "\\.") -- tokenize
      local name = prov_tbl[#prov_tbl] -- last token should be server name
      log.debug(fmt("Configuring server '%s', with config: %s", name, config))
      lspconfig[name].setup(config)
    end
  end

  -- Configure null-ls
  require(fmt("%s.null-ls", mod))(options)
end

return M
