return function()
  local prequire = require("conf.utils.prequire")
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- Add additional capabilities supported by nvim-cmp
  local cmp_lsp = prequire("cmp_nvim_lsp")
  if cmp_lsp then
    capabilities = cmp_lsp.default_capabilities()
  end
  return capabilities
end
