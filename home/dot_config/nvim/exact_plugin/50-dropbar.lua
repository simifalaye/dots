local lazy = require("utils.lazy")

lazy.now(function()
  vim.pack.add({
    { src = "https://github.com/Bekaboo/dropbar.nvim" },
  })

  vim.api.nvim_set_hl(0, "DropBarFileCurrent", { bold = true, link = "Title" })
  vim.api.nvim_set_hl(
    0,
    "DropBarFileCurrentModified",
    { bold = true, link = "WarningMsg" }
  )

  local dropbar = require("dropbar")
  dropbar.setup({
    bar = {
      enable = function(buf, win, _)
        buf = vim._resolve_bufnr(buf)
        if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
          return false
        end

        if
          vim.fn.win_gettype(win) ~= ""
          or vim.wo[win].winbar ~= ""
          or vim.bo[buf].ft == "help"
        then
          return false
        end

        local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
        if stat and stat.size > 1024 * 1024 then
          return false
        end

        return vim.bo[buf].bt == "terminal"
          or vim.bo[buf].ft == "markdown"
          or pcall(vim.treesitter.get_parser, buf)
          or not vim.tbl_isempty(vim.lsp.get_clients({
            bufnr = buf,
            method = "textDocument/documentSymbol",
          }))
      end,
      update_debounce = 100,
      sources = function(buf, _)
        local sources = require("dropbar.sources")
        local utils = require("dropbar.utils")

        if vim.bo[buf].ft == "markdown" then
          return { sources.markdown }
        end
        if vim.bo[buf].buftype == "terminal" then
          return { sources.terminal }
        end
        return {
          {
            -- wrap path source and mark the current file (last symbol) with a bold hl
            get_symbols = function(b, w, c)
              local symbols = sources.path.get_symbols(b, w, c)
              if #symbols > 0 then
                symbols[#symbols].name_hl = vim.bo[buf].modified
                    and "DropBarFileCurrentModified"
                  or "DropBarFileCurrent"
              end
              return symbols
            end,
          },
          utils.source.fallback({
            sources.lsp,
            sources.treesitter,
          }),
        }
      end,
    },
    sources = {
      path = {
        relative_to = function(buf, win)
          -- Show full path in oil or fugitive buffers
          local bufname = vim.api.nvim_buf_get_name(buf)
          if
            vim.startswith(bufname, "oil://") or vim.startswith(bufname, "fugitive://")
          then
            local root = bufname:gsub("^%S+://", "", 1)
            while root and root ~= vim.fs.dirname(root) do
              root = vim.fs.dirname(root)
            end
            return root
          end

          local ok, cwd = pcall(vim.fn.getcwd, win)
          return ok and cwd or vim.fn.getcwd()
        end,
      },
    },
  })
end)
