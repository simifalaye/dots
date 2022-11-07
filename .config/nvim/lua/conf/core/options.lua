-- Read documentation about each option by executing :h <option>
local g, o, fn, opt = vim.g, vim.o, vim.fn, vim.opt
local utils = require("conf.utils")

-- Timings
----------
opt.updatetime = 300
opt.timeout = true
opt.timeoutlen = 300
opt.ttimeoutlen = 10

-- Splits and buffers
---------------------
opt.splitbelow = true
opt.splitright = true
opt.equalalways = false
o.switchbuf = "useopen,uselast"

-- Format Options
-----------------
opt.formatoptions = {
  ["1"] = true,
  ["2"] = true, -- Use indent from 2nd line of a paragraph
  q = true, -- continue comments with gq"
  c = true, -- Auto-wrap comments using textwidth
  r = true, -- Continue comments when pressing Enter
  n = true, -- Recognize numbered lists
  t = false, -- autowrap lines using text width value
  j = true, -- remove a comment leader when joining lines.
  -- Only break if the line was not longer than 'textwidth' when the insert
  -- started and only at a white character that has been entered during the
  -- current insert command.
  l = true,
  v = true,
}

-- Folds
--------
opt.foldlevelstart = 3
opt.foldenable = false -- don't fold by default
opt.foldlevel = 1

-- Grepprg
----------
if utils.executable("rg") then
  o.grepprg = [[rg --glob "!.git" --no-heading --vimgrep --follow $*]]
  opt.grepformat = opt.grepformat ^ { "%f:%l:%c:%m" }
elseif utils.executable("ag") then
  o.grepprg = [[ag --nogroup --nocolor --vimgrep]]
  opt.grepformat = opt.grepformat ^ { "%f:%l:%c:%m" }
end

-- Wild/File globbing in cmd mode
---------------------------------
opt.wildmode = "longest:full,full"
opt.wildignorecase = true

-- Display
----------
opt.conceallevel = 2
opt.breakindentopt = "sbr"
opt.linebreak = true -- lines wrap at words rather than random characters
opt.synmaxcol = 1024 -- don't syntax highlight long lines
opt.signcolumn = "yes"
opt.ruler = false
opt.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.laststatus = 3 -- global statusline

-- List chars
-------------
opt.list = true -- invisible chars
opt.listchars = {
  tab = "»·",
  nbsp = "+",
  trail = "·",
  extends = "→",
  precedes = "←",
  eol = nil,
}

-- Indentation
--------------
opt.wrap = true
opt.wrapmargin = 2
opt.smartindent = true
opt.expandtab = true
opt.autoindent = true
opt.shiftround = true
opt.textwidth = 80
opt.tabstop = 4
opt.shiftwidth = 2

-- Backup and Swap
------------------
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
if fn.isdirectory(o.undodir) == 0 then
  fn.mkdir(o.undodir, "p")
end

-- Match and Search
-------------------
opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true
opt.scrolloff = 10
opt.sidescrolloff = 10
opt.sidescroll = 1
opt.showmatch = true
opt.completeopt = { "menuone", "noselect" }

-- Spelling
-----------
opt.spelloptions = "camel"
opt.spellcapcheck = ""

-- Mouse
--------
opt.mouse = "a"
opt.mousefocus = true

-- Utilities
------------
opt.cmdheight = 0
opt.showmode = false
opt.viewoptions = { "cursor", "folds" } -- save/restore with sessions
opt.virtualedit = "block"
opt.lazyredraw = true
opt.pastetoggle = "<F5>"
-- opt.clipboard = "unnamedplus"

-- Filetype
-----------
-- Use filetype.lua instead of vim
g.do_filetype_lua = 1
-- g.did_load_filetypes = 0

-- Disable unused built-in plugins
----------------------------------
local default_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}

for _, plugin in pairs(default_plugins) do
  g["loaded_" .. plugin] = 1
end
