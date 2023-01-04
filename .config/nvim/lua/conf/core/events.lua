local api = vim.api
local cmd = vim.cmd

-- Utilities
local au_utils = api.nvim_create_augroup("Utilities", {})
api.nvim_create_autocmd("BufWritePre", {
  group = au_utils,
  desc = "Remove trailing whitespace on save",
  pattern = "*",
  callback = function()
    local ft = vim.bo.filetype
    local ignore = { "ruby", "perl", "markdown", "gitsendemail", "gitcommit" }
    for _, val in ipairs(ignore) do
      if string.match(ft, val) then
        return
      end
    end
    cmd([[ %s/\s\+$//e ]])
  end,
})
api.nvim_create_autocmd("BufReadPost", {
  group = au_utils,
  desc = "Jump to last known position and center buffer around cursor",
  pattern = "*",
  callback = function()
    if vim.bo.ft ~= "gitcommit" and vim.fn.win_gettype() ~= "popup" then
      local last_place_mark = vim.api.nvim_buf_get_mark(0, '"')
      local line_nr = last_place_mark[1]
      local last_line = vim.api.nvim_buf_line_count(0)

      if line_nr > 0 and line_nr <= last_line then
        vim.api.nvim_win_set_cursor(0, last_place_mark)
      end
    end
  end,
})
api.nvim_create_autocmd({ "BufWritePre", "FileWritePre" }, {
  group = au_utils,
  desc = "Use mkdir -p when writing file path that doesn't exist",
  pattern = "*",
  command = "silent! call mkdir(expand('<afile>:p:h'), 'p')",
})

-- WindowBehaviours
local au_win = api.nvim_create_augroup("WindowBehaviours", {})
api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
  group = au_win,
  desc = "Jump to quickfix window when opened",
  pattern = { "[^l]*" },
  command = "cwindow",
  nested = true,
})
api.nvim_create_autocmd({ "QuickFixCmdPost" }, {
  group = au_win,
  desc = "Jump to loclist window when opened",
  pattern = { "l*" },
  command = "lwindow",
  nested = true,
})
api.nvim_create_autocmd({ "VimResized" }, {
  group = au_win,
  desc = "Auto-resize splits",
  pattern = { "*" },
  command = "wincmd =",
})
api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  group = au_win,
  desc = "Highlight window when focused",
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = true
    vim.opt.cursorline = true
  end,
})
api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
  group = au_win,
  desc = "Un-highlight window when un-focused",
  pattern = "*",
  callback = function()
    vim.opt.relativenumber = false
    vim.opt.cursorline = false
  end,
})
