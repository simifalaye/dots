-- Helper for modularizing plugins
----------------------------------
-- Each plugin can separate it's config into individual files and define the
-- following module schema:
--    def (table): the packer plugin definition
--      > Note, you can use the "disable" table field to disable
--    init (function)[opt]: code to run before any plugins are loaded
--    setup (function)[opt]: packer setup function (reloaded every boot)
--    config (function)[opt]: packer config function (reloaded every boot)
local mod = (...):gsub("%.init$", "")
local fmt = string.format
local log = require("conf.utils.log")
local utils = require("conf.utils")
local prequire = require("conf.utils.prequire")
local getmodlist = require("conf.utils.autorequire").getmodlist

-- Boostrap
-- ===========

-- Make sure packer is installed and load it
local packer_bootstrap = nil
local install_path = utils.join_paths(utils.packer_dir, "packer.nvim")
---@diagnostic disable-next-line: missing-parameter
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  log.info("Installing packer...")
  packer_bootstrap = vim.fn.system({
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  })
  vim.cmd("packadd packer.nvim")
end

-- Use a protected call so we don't error out on first use
local packer = prequire("packer")
if not packer then
  return
end

-- Configure
packer.init({
  auto_clean = true,
  compile_on_sync = true,
  git = {
    clone_timeout = 6000,
  },
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "single" })
    end,
  },
})

-- Load
-- =======

local modlist = getmodlist("conf.plugins", {})
local plugins = {
  -- Core
  {
    "wbthomason/packer.nvim",
    config = function()
      local m = require("conf.utils.map")
      m.group("<leader>p", "+plugin")
      m.nnoremap("<leader>pc", "<cmd>PackerCompile<CR>", "Compile")
      m.nnoremap("<leader>pi", "<cmd>PackerInstall<CR>", "Install")
      m.nnoremap("<leader>pp", "<cmd>PackerSync<CR>", "Sync")
      m.nnoremap("<leader>ps", "<cmd>PackerStatus<CR>", "Status")
    end,
  },
  { "lewis6991/impatient.nvim" },
  -- Utility
  { "kevinhwang91/nvim-bqf", ft = "qf" },
  { "tweekmonster/startuptime.vim", cmd = "StartupTime" },
  {
    "kylechui/nvim-surround",
    event = "BufRead",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  {
    "numToStr/Comment.nvim",
    tag = "v0.6",
    keys = { "gc", "gb", "g>", "g<" },
    config = function()
      require("Comment").setup({})
    end,
  },
  {
    "nmac427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup({})
    end,
  },
}

-- Get plugin names from each file
for _, modname in pairs(modlist) do
  if modname ~= mod .. ".init" then
    local module = require(modname)
    if module.def then
      for _, plugin in pairs(module.def) do
        if module.disable then
          plugin.cmd = "nil_cmd"
        end
        -- Add config and setup function calls
        if module.setup then
          plugin.setup = fmt("require('%s').setup()", modname)
        end
        if module.config then
          plugin.config = fmt("require('%s').config()", modname)
        end
        -- Run init function
        if (not plugin.disable or plugin.disable == false) and module.init then
          module.init()
        end
        -- Insert into table
        table.insert(plugins, plugin)
      end
    else
      log.error("Each plugin file must define plugins: " .. modname)
    end
  end
end

-- Load plugins
packer.startup(function(use)
  for _, plugin in pairs(plugins) do
    use(plugin)
  end
  -- Automatically install plugins on initial bootup (must be after the plugins
  -- have been defined)
  if packer_bootstrap then
    require("packer").sync()
  end
end)
