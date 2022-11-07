return function(client, _)
  if client and client.server_capabilities.code_lens then
    vim.api.nvim_create_autocmd({
      "BufEnter",
      "CursorHold",
      "InsertLeave",
    }, {
      desc = "Refresh codelens often",
      pattern = "<buffer>",
      callback = vim.lsp.codelens.refresh,
    })
  end
  if client and client.server_capabilities.document_highlight then
    local au_doc_hi = vim.api.nvim_create_augroup("LspDocumentHighlight", {})
    vim.api.nvim_create_autocmd("CursorHold", {
      group = au_doc_hi,
      desc = "Highlight references on cursor hold",
      pattern = "<buffer>",
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = au_doc_hi,
      desc = "Clear reference highlights on cursor move",
      pattern = "<buffer>",
      callback = vim.lsp.buf.clear_references,
    })
  end
end
