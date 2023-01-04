--[[

Neovim inint file
Nvim version: 0.8.0+
Maintainer: simifalaye

--]]

-- Map leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load globals
require("conf.globals")

-- Install lazy plugin manager if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

-- Add to runtime path
vim.opt.rtp:prepend(lazypath)

-- Load lazy and configure
require("lazy").setup("conf.plugins", {
  defaults = { lazy = true },
  install = {
    colorscheme = { "base16-" .. vim.env.BASE16_THEME },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Load core modules
require("conf.core.options")
require("conf.core.commands")
require("conf.core.events")
require("conf.core.keymaps")
