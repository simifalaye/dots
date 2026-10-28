local lazy = require("utils.lazy")

local cfg = {
  ignore_runnables = true,
}

lazy.now_if_args(function()
  local runnable_prefix = "run_"

  local grp = vim.api.nvim_create_augroup("user.plugin.chezmoi", {})
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Disable diagnostics for template buffers",
    group = grp,
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      if not client or not vim.api.nvim_buf_get_name(bufnr):match("%.tmpl$") then
        return
      end

      -- Disable diagnostics for template buffers
      client.handlers["textDocument/publishDiagnostics"] = function() end
      vim.lsp.buf_detach_client(bufnr, client.id)
      vim.diagnostic.enable(false, { bufnr = bufnr })
      vim.diagnostic.reset(nil, bufnr)
    end,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    desc = "Apply chezmoi files on save",
    group = grp,
    pattern = { vim.env.HOME .. "/.local/share/chezmoi/*" },
    callback = function(args)
      local filename = vim.fn.fnamemodify(args.file, ":t")
      if
        not cfg.ignore_runnables or filename:sub(1, #runnable_prefix) ~= runnable_prefix
      then
        vim.system({ "chezmoi", "apply", "--source-path", args.file }, { detach = true })
      end
    end,
  })

  if vim.env.USERPROFILE and vim.fn.executable("wapp") == 1 then
    vim.api.nvim_create_autocmd("BufWritePost", {
      desc = "Apply windows chezmoi files on save",
      group = grp,
      pattern = { vim.env.USERPROFILE .. "/.local/share/chezmoi/*" },
      callback = function(args)
        local filename = vim.fn.fnamemodify(args.file, ":t")
        if
          not cfg.ignore_runnables
          or filename:sub(1, #runnable_prefix) ~= runnable_prefix
        then
          vim.system(
            { "wapp", "chezmoi", "apply", "--source-path", args.file },
            { detach = true }
          )
        end
      end,
    })
  end
end)
