---@diagnostic disable: assign-type-mismatch
local opt = vim.opt
local g = vim.g

-- Misc
opt.clipboard = "unnamedplus"
opt.encoding = "utf-8"
opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
opt.syntax = "enable"

-- Indention
opt.autoindent = true
opt.expandtab = true
opt.shiftwidth = 2
opt.shiftround = true
opt.smartindent = true
opt.softtabstop = 2
opt.tabstop = 2

-- Search
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.wildignore = opt.wildignore
  + { "*/node_modules/*", "*/.git/*", "*/vendor/*" }
opt.wildmenu = true

-- Ui
opt.cmdheight = 0
opt.cursorline = true
opt.laststatus = 3 -- global statusline
opt.lazyredraw = true
opt.list = true
opt.listchars = {
  tab = "»·",
  nbsp = "+",
  trail = "·",
  extends = "→",
  precedes = "←",
  eol = nil,
}
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.scrolloff = 10
opt.sidescrolloff = 10 -- Lines to scroll horizontally
opt.showmode = false
opt.signcolumn = "yes"
opt.splitbelow = true -- Open new split below
opt.splitright = true -- Open new split to the right
opt.wrap = false
opt.showbreak = [[↪ ]] -- Options include -> '…', '↳ ', '→','↪ '
opt.termguicolors = true

-- Backups
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
if vim.fn.isdirectory(vim.o.undodir) == 0 then
  vim.fn.mkdir(vim.o.undodir, "p")
end

-- Autocomplete
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess = opt.shortmess + { c = true }

-- Perfomance
opt.redrawtime = 1500
opt.timeoutlen = 250
opt.ttimeoutlen = 10
opt.updatetime = 250

-- Filetype
g.do_filetype_lua = 1 -- use filetype.lua when possible
