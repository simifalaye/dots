local log = require("conf.utils.log")
local colors = require("conf.utils.colors")
local cmd = vim.cmd

-- Fixes bckgrd color issues (wsl support)
cmd([[
    if &term =~ '256color'
        " Disable Background Color Erase (BCE) so that color schemes
        " work properly when Vim is used inside tmux and GNU screen.
        set t_ut=
    endif
]])

-- Enable true color support
vim.go.t_Co = "256"
if vim.fn.has("termguicolors") == 1 then
  log.debug("Has termguicolors")
  vim.go.t_8f = "[[38;2;%lu;%lu;%lum"
  vim.go.t_8b = "[[48;2;%lu;%lu;%lum"
  vim.opt.termguicolors = true
end

-- Apply colorscheme
colors.apply_colorscheme()
