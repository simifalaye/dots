local lazy = require("utils.lazy")

lazy.later(function()
  vim.pack.add({
    { src = "https://github.com/tpope/vim-rhubarb" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/justinmk/vim-ug" },
  })

  -- Autocmds
  local grp = vim.api.nvim_create_augroup("user.plugin.fugitive", {})
  vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Ensure that fugitive buffers are not listed and are wiped out after hidden.",
    group = grp,
    pattern = "fugitive://*",
    callback = function(info)
      vim.bo[info.buf].buflisted = false
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Set buffer-local options for fugitive buffers.",
    group = grp,
    pattern = "fugitive",
    callback = function()
      vim.opt_local.winbar = nil
      vim.opt_local.signcolumn = "no"
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    desc = "Set buffer-local options for fugitive blame buffers.",
    group = grp,
    pattern = "fugitiveblame",
    callback = function()
      local win_alt = vim.fn.win_getid(vim.fn.winnr("#"))
      vim.opt_local.winbar = vim.api.nvim_win_is_valid(win_alt)
          and vim.wo[win_alt].winbar ~= ""
          and " "
        or ""

      vim.opt_local.number = false
      vim.opt_local.signcolumn = "no"
      vim.opt_local.relativenumber = false
    end,
  })
end)
