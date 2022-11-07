return function(client, bufnr)
  local m = require("conf.utils.map")

  -- Handle global keymaps
  if not client or not bufnr then
    m.nnoremap("<leader>lI", "<cmd>LspInfo<CR>", "Lsp Info")
    m.nnoremap("<leader>lS", "<cmd>LspStart<CR>", "Lsp Start")
    m.nnoremap("<leader>lT", "<cmd>LspStop<CR>", "Lsp Stop")
    return
  end

  local o = { buffer = bufnr }
  local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")

  m.nnoremap("[d", vim.diagnostic.goto_prev, "Goto prev diag (LSP)", o)
  m.nnoremap("]d", vim.diagnostic.goto_next, "Goto next diag (LSP)", o)
  m.nnoremap("gd", vim.lsp.buf.definition, "Goto def (LSP)", o)
  m.nnoremap("gD", vim.lsp.buf.declaration, "Goto dec (LSP)", o)
  if client.server_capabilities.implementation then
    m.nnoremap("gi", vim.lsp.buf.implementation, "Goto impl (LSP)", o)
  end
  m.nnoremap("gr", vim.lsp.buf.references, "Goto ref (LSP)", o)
  m.nnoremap("K", vim.lsp.buf.hover, "Hover (LSP)", o)

  m.group("<leader>l", "+lsp")
  m.nnoremap("<leader>la", vim.lsp.buf.code_action, "Code action", o)
  m.vnoremap(
    "<leader>la",
    ":<C-U>lua vim.lsp.buf.range_code_action()<CR>",
    "Code action",
    o
  )
  m.nnoremap("<leader>ld", vim.diagnostic.open_float, "Diagnostics", o)
  if client.server_capabilities.documentFormattingProvider then
    m.nnoremap("<leader>lf", vim.lsp.buf.format, "Format", o)
  end
  m.nnoremap("<leader>lr", vim.lsp.buf.rename, "Rename", o)
  if ft == "c" or ft == "cpp" then
    m.nnoremap("<leader>ls", "<cmd>ClangdSwitchSourceHeader<CR>", "Goto alt", o)
  end
  if client.server_capabilities.type_definition then
    m.nnoremap("<leader>lt", vim.lsp.buf.type_definition, "Goto type", o)
  end
end
