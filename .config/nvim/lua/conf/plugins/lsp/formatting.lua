return function(client, bufnr)
  local prequire = require("conf.utils.prequire")
  local function has_null_formatter(ft)
    local sources = prequire("null-ls.sources")
    if not sources then
      return false
    end
    local available = sources.get_available(ft, "NULL_LS_FORMATTING")
    return #available > 0
  end

  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
  if has_null_formatter(ft) and client.name ~= "null-ls" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
end
