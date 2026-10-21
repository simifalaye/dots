local map = vim.keymap.set

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Disable unused builtin plugins
vim.g.loaded_netrw = true
vim.g.loaded_netrwPlugin = true
vim.g.loaded_netrwSettings = true
vim.g.loaded_netrwFileHandlers = true
vim.g.loaded_gzip = true
vim.g.loaded_zip = true
vim.g.loaded_zipPlugin = true
vim.g.loaded_tar = true
vim.g.loaded_tarPlugin = true
vim.g.loaded_tutor_mode_plugin = true
vim.g.loaded_getscript = true
vim.g.loaded_getscriptPlugin = true
vim.g.loaded_vimball = true
vim.g.loaded_vimballPlugin = true
vim.g.loaded_tohtml = true
vim.g.loaded_2html_plugin = true

-- Enable clipboard
vim.schedule(function()
  if vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
    }
  end
  vim.opt.clipboard = "unnamedplus"
end)

--
-- Options
--

-- General
vim.opt.mouse = "a"
vim.opt.mousescroll = "ver:25,hor:6"
vim.opt.switchbuf = "usetab"
vim.opt.undofile = true
vim.opt.shada = "'100,<50,s10,:1000,/100,@100,h"
vim.opt.exrc = true
vim.opt.swapfile = false -- TODO: Evaluate
vim.opt.confirm = true

-- UI
vim.opt.breakindent = true
vim.opt.breakindentopt = "list:-1"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "screenline,number"
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = "tab:> ,extends:…,precedes:…,nbsp:␣"
vim.opt.fillchars = "eob: "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.pumheight = 10
vim.opt.pummaxwidth = 100
vim.opt.ruler = false
vim.opt.shortmess = "CFOWaco"
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "screen"
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 2
vim.opt.sidescrolloff = 16
vim.opt.completetimeout = 100
vim.opt.cmdheight = 0
vim.opt.statusline = "%!v:lua.require'statusline'.render()"

-- Editing
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.formatoptions = "rqnl1j"
vim.opt.ignorecase = true
vim.opt.infercase = true
vim.opt.shiftwidth = 2
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.virtualedit = "block"
-- Define pattern for a start of 'numbered' list. This is responsible for
-- correct formatting of lists when using `gw`. This basically reads as 'at
-- least one special character (digit, -, +, *) possibly followed some
-- punctuation (. or `)`) followed by at least one space is a start of list
-- item'
vim.opt.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- Completion
vim.opt.complete = ".,w,b,kspell"
vim.opt.completeopt = "menuone,noselect,fuzzy,nosort"
vim.opt.wildmode = "noselect,full"
vim.opt.wildoptions = "fuzzy,pum"

-- Spelling
vim.opt.spelllang = "en,uk"
vim.opt.spelloptions = "camel"

-- Folds
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldnestmax = 10
vim.g.markdown_folding = 1
vim.opt.foldtext = ""

--
-- Autocommands
--

local augroup = vim.api.nvim_create_augroup("user.config", {})

vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Enable ui2 on UIEnter (for when nvim is started with `--headless`)",
  group = augroup,
  callback = function()
    local ui2 = require("vim._core.ui2")
    ui2.enable({ enable = true, msg = { targets = "msg" } })
    ui2.check_targets() -- Ensure bufs and wins are created immediately
  end,
  once = true,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Jump to last known position and center buffer around cursor",
  group = augroup,
  pattern = "*",
  callback = function(event)
    local exclude = { "gitcommit", "popup" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].user_last_loc then
      return
    end
    vim.b[buf].user_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  desc = "Disable automatic comment formatting",
  group = augroup,
  callback = function()
    vim.opt_local.formatoptions = vim.opt_local.formatoptions - { "c", "o" }
  end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text and restore cursor position",
  group = augroup,
  callback = function()
    if vim.fn.has("nvim-0.13") == 1 then
      vim.hl.hl_op({ timeout = 200, higroup = "IncSearch" })
    else
      vim.highlight.on_yank({ timeout = 200, higroup = "IncSearch" })
    end
    if vim.v.event.operator == "y" and vim.b.cursor_pre_yank then
      vim.api.nvim_win_set_cursor(0, vim.b.cursor_pre_yank)
      vim.b.cursor_pre_yank = nil
    end
  end,
})
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  desc = "Setup buffer-local lsp configuration on attach",
  callback = function(args)
    local bufnr = args.buf --[[@as number]]
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end

    -- Disable diagnostics for tmpl buffers
    if vim.api.nvim_buf_get_name(bufnr):match("%.tmpl$") then
      client.handlers["textDocument/publishDiagnostics"] = function() end
    end

    -- Workspace folders
    map("n", "<localleader>wa", vim.lsp.buf.add_workspace_folder, {
      desc = "Add workspace folder (LSP)",
      buffer = bufnr,
    })
    map("n", "<localleader>wr", vim.lsp.buf.remove_workspace_folder, {
      desc = "Remove workspace folder (LSP)",
      buffer = bufnr,
    })
    map("n", "<localleader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, {
      desc = "List workspace folders (LSP)",
      buffer = bufnr,
    })

    -- Diagnostics and inlay hints
    map("n", "<bs>", function()
      vim.diagnostic.config({
        virtual_lines = not vim.diagnostic.config().virtual_lines,
      })
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, {
      desc = "Toggle verbose diagnostics and inlay hints",
      buffer = bufnr,
    })

    map("n", "gK", vim.diagnostic.open_float, {
      desc = "Show diagnostics in a floating window",
      buffer = bufnr,
    })

    -- LSP actions
    map({ "n", "x" }, "<localleader>a", vim.lsp.buf.code_action, {
      desc = "Code action (LSP)",
      buffer = bufnr,
    })
    map("n", "<localleader>i", vim.lsp.buf.implementation, {
      desc = "Go to implementation (LSP)",
      buffer = bufnr,
    })
    map("n", "<localleader>n", vim.lsp.buf.rename, {
      desc = "Rename symbol (LSP)",
      buffer = bufnr,
    })
    map("n", "<localleader>r", vim.lsp.buf.references, {
      desc = "Find references (LSP)",
      buffer = bufnr,
    })
    map("n", "<localleader>t", vim.lsp.buf.type_definition, {
      desc = "Go to type definition (LSP)",
      buffer = bufnr,
    })
    map("n", "<localleader>x", vim.lsp.codelens.run, {
      desc = "Run code lens (LSP)",
      buffer = bufnr,
    })

    local supports_method = function(method)
      return client:supports_method("textDocument/" .. method)
    end

    -- Declaration
    if supports_method("declaration") then
      map("n", "<localleader>d", vim.lsp.buf.declaration, {
        desc = "Go to declaration (LSP)",
        buffer = bufnr,
      })
    end

    -- Document highlights
    if supports_method("documentHighlight") then
      local doc_highlight_grp =
        vim.api.nvim_create_augroup("user.lsp.doc_highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = doc_highlight_grp,
        desc = "Highlight references when cursor holds",
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.document_highlight()
        end,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = doc_highlight_grp,
        desc = "Clear references when cursor moves",
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.clear_references()
        end,
      })
    end

    -- Optional built-in LSP completion
    -- if supports_method("completion") then
    --   vim.lsp.completion.enable(true, client.id, bufnr, {
    --     autotrigger = true,
    --   })
    -- end
  end,
})
vim.api.nvim_create_autocmd("LspProgress", {
  desc = "Display lsp progress",
  group = augroup,
  callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or "done" } }, false, {
      id = "lsp." .. ev.data.client_id,
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})
if vim.fn.has("nvim-0.13") ~= 1 then
  vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    desc = "Check if we need to reload the file when it changed",
    group = augroup,
    callback = function()
      if vim.o.buftype ~= "nofile" then
        vim.cmd("silent! checktime")
      end
    end,
  })
end

--
-- Commands
--

local function complete_pack_names(arglead)
  local items = {}
  local packs = (vim.pack and vim.pack.get) and vim.pack.get(nil, { info = false }) or {}

  for _, plug in ipairs(packs) do
    local name = tostring(plug.spec.name) ---@type string
    if arglead == "" or name:find("^" .. vim.pesc(arglead)) then
      items[#items + 1] = name
    end
  end

  table.sort(items)
  return items
end

vim.api.nvim_create_user_command("PackAdd", function(opts)
  local src = opts.fargs[1]
  local version = opts.fargs[2]

  ---@type vim.pack.Spec
  local spec = { src = src }
  if version and version ~= "" then
    spec.version = version
  end

  vim.pack.add({ spec })
end, {
  desc = "vim.pack.add wrapper: :PackAdd {src} [version]",
  nargs = "+", -- {src,version?}
  complete = "file",
})

vim.api.nvim_create_user_command("PackDel", function(opts)
  vim.pack.del(opts.fargs, { force = opts.bang })
end, {
  desc = "vim.pack.del wrapper: :PackDel[!] {name} ... (use ! to force)",
  bang = true,
  nargs = "+",
  complete = function(arglead, _, _)
    return complete_pack_names(arglead)
  end,
})

vim.api.nvim_create_user_command("PackGet", function(opts)
  local names = (#opts.fargs > 0) and opts.fargs or nil
  local info = not opts.bang

  local res = vim.pack.get(names, { info = info })
  vim.print(res)
end, {
  desc = "vim.pack.get wrapper: :PackGet[!] [name ...] (! => info=false)",
  bang = true,
  nargs = "*",
  complete = function(arglead, _, _)
    return complete_pack_names(arglead)
  end,
})

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  local names = (#opts.fargs > 0) and opts.fargs or nil
  vim.pack.update(names, { force = opts.bang })
end, {
  desc = "vim.pack.update wrapper: :PackUpdate[!] [name ...] (! => force)",
  bang = true,
  nargs = "*",
  complete = function(arglead, _, _)
    return complete_pack_names(arglead)
  end,
})

vim.api.nvim_create_user_command("PackClean", function()
  local plugs = vim.pack.get(nil, nil)
  local remove_list = {}
  for _, plug in ipairs(plugs) do
    if not plug.active and plug.spec then
      table.insert(remove_list, plug.spec.name)
    end
  end
  vim.pack.del(remove_list)
end, { desc = "Clean inactive plugins", nargs = 0 })

vim.api.nvim_create_user_command("R", function(opts)
  if not opts.bang then
    vim.cmd.wincmd("n")
  end

  local cmd = opts.args:gsub("'", "''"):gsub('"', '\\"')
  vim.cmd("put=execute('" .. cmd .. "')")
end, {
  desc = "Execute command and put result into a buffer (or current with '!')",
  nargs = "+",
  bang = true,
  complete = "command",
})

--
-- Keymaps
--

-- Save
map("n", "<C-s>", "<Cmd>silent! update | redraw<CR>", { desc = "Save" })
map(
  { "i", "x" },
  "<C-s>",
  "<Esc><Cmd>silent! update | redraw<CR>",
  { desc = "Save and go to Normal mode" }
)

-- Move through wrapped lines
map(
  { "n", "x" },
  "j",
  "v:count == 0 ? 'gj' : 'j'",
  { desc = "Down", expr = true, silent = true }
)
map(
  { "n", "x" },
  "<Down>",
  "v:count == 0 ? 'gj' : 'j'",
  { desc = "Down", expr = true, silent = true }
)
map(
  { "n", "x" },
  "k",
  "v:count == 0 ? 'gk' : 'k'",
  { desc = "Up", expr = true, silent = true }
)
map(
  { "n", "x" },
  "<Up>",
  "v:count == 0 ? 'gk' : 'k'",
  { desc = "Up", expr = true, silent = true }
)

-- Yank/Put remaps
map({ "n", "x" }, "y", function()
  vim.b.cursor_pre_yank = vim.api.nvim_win_get_cursor(0)
  return "y"
end, { desc = "Yank, keep cursor", expr = true })
map("n", "Y", function()
  vim.b.cursor_pre_yank = vim.api.nvim_win_get_cursor(0)
  return "y$"
end, { desc = "Yank eol, keep cursor", expr = true })
map("n", "p", "p`[v`]=", { desc = "Paste & Format" })

-- System clipboard integration
map({ "n", "x" }, "gy", '"+y', { desc = "Copy to system clipboard" })
map("n", "gyY", "<cmd>%y+<CR>", { desc = "Yank entire file to system clipboard" })
map(
  "n",
  "gy%",
  "<cmd>let @+=fnamemodify(@%, ':.')<cr>",
  { desc = "Copy current relative filename to system clipboard" }
)
map("n", "gp", '"+p', { desc = "Paste from system clipboard" })
map("x", "gp", '"+P', { desc = "Paste from system clipboard" })

-- Format buffer
map("n", "gq<CR>", "mzgggqG`z", { desc = "Format entire buffer" })
map("n", "gq?", "<cmd>set formatprg? formatexpr?<CR>", { desc = "Shor format settings" })

-- Run lua
map("n", "g:", ":lua=", { desc = "Run lua code" })

-- Search mark and center
map("n", "/", "ms/", { desc = "Search forward with mark" })
map("n", "?", "ms?", { desc = "Search backwards with mark" })
map("n", "n", "nzzzv", { desc = "Search next and center cursor" })
map("n", "N", "Nzzzv", { desc = "Search prev and center cursor" })

-- Change directory
map(
  "n",
  "cd%",
  "<cmd>lcd %:h<bar>verbose pwd<cr>",
  { desc = "Change local directory to current file's directory" }
)
map("n", "cdd", function()
  local root = vim.fs.root(0, ".git")
  if root then
    vim.cmd.lcd({ args = { root } })
    vim.cmd.pwd()
  end
end, { desc = "Change local directory to Git root" })
map(
  "n",
  "cdu",
  "<cmd>lcd ..<bar>verbose pwd<cr>",
  { desc = "Change local directory to parent directory" }
)
map(
  "n",
  "cd-",
  "<cmd>lcd -<bar>verbose pwd<cr>",
  { desc = "Return to previous local directory" }
)

-- Filename and directory insertion
map("c", "<M-%>", "<C-r>=fnamemodify(@%, ':t')<cr>", { desc = "Insert filename" })
map("c", "<M-S-5>", "<M-%>", { desc = "Insert filename" })
map(
  { "i", "c" },
  "<M-/>",
  "<C-r>=expand('%:.:h', 1)<cr>",
  { desc = "Insert file's directory" }
)
map(
  { "i", "c" },
  "<C-r>?",
  "<C-r>=substitute(getreg('/'), '[<>\\]', '', 'g')<cr>",
  { desc = "Insert search pattern" }
)

-- Make executable
map("n", "g!", ":! chmod +x %<CR>", { desc = "Make File Executable" })

-- Messages
map(
  "n",
  "g>",
  [[<cmd>set nomore<bar>echo repeat("\n",&cmdheight)<bar>40messages<bar>set more<CR>]],
  { desc = "Show Message History" }
)
map("n", "g<", [[<cmd>messages clear<CR>]], { desc = "Clear Message History" })

-- Search
map(
  "n",
  "*",
  [[ms:<c-u>let @/='\V\<'.escape(expand('<cword>'), '/\').'\>'<bar>call histadd('/',@/)<bar>set hlsearch<cr>]],
  { silent = true, desc = "Search whole word forward without moving" }
)
map(
  "n",
  "g*",
  [[ms:<c-u>let @/='\V' . escape(expand('<cword>'), '/\')<bar>call histadd('/',@/)<bar>set hlsearch<cr>]],
  { silent = true, desc = "Search partial word forward without moving" }
)
map("x", "g/", "<esc>/\\%V", { silent = false, desc = "Search inside visual selection" })

-- Selection and repeat
map("n", "gV", "`[v`]", { desc = "Select last changed or inserted text" })
map("x", ".", ":normal .<CR>", { desc = "Repeat last change on each selected line" })
map(
  "n",
  "gn",
  ":normal n.<CR>",
  { silent = true, desc = "Repeat last change at next search match" }
)

-- Redraw and clear
map("n", "<C-l>", function()
  if vim.v.count > 0 then
    vim.cmd("call clearmatches()")
    vim.api.nvim_buf_clear_namespace(0, -1, 0, -1)
  end
  vim.cmd("nohlsearch")
  vim.cmd("diffupdate")
  vim.cmd("syncbind")
  vim.api.nvim_buf_clear_namespace(
    0,
    vim.api.nvim_create_namespace("nvim.multicursor"),
    0,
    -1
  )
  vim.cmd("normal! <C-l>")
end, { silent = true, desc = "Redraw screen, clear search highlights and multicursors" })

-- Terminal mode
map("t", "<M-;>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- Close buffers
map("n", "ZB", "<cmd>bp | bd #<CR>", { desc = "Delete buffer" })
map("n", "ZK", ":bufdo bd!<CR>", { desc = "Killall buffers" })
map("n", "ZO", function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf and vim.bo[buf].buflisted == true then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  vim.notify("Deleted other buffers")
end, { desc = "Delete other buffers" })

-- g?: Web search
vim.keymap.set("n", "g??", function()
  vim.ui.open(("https://google.com/search?q=%s"):format(vim.fn.expand("<cword>")))
end)
vim.keymap.set("x", "g??", function()
  vim.ui.open(
    ("https://google.com/search?q=%s"):format(
      vim.trim(
        table.concat(
          vim.fn.getregion(
            vim.fn.getpos("."),
            vim.fn.getpos("v"),
            { type = vim.fn.mode() }
          ),
          " "
        )
      )
    )
  )
  vim.api.nvim_input("<esc>")
end)

-- Pickers
map("n", "<leader>b", function()
  vim.api.nvim_feedkeys(":b ", "n", false)
  vim.schedule(function()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
      "t",
      false
    )
  end)
end, { desc = "Find Buffer" })
map("n", "<leader>f", function()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.fnamemodify(buf_path, ":p:h")
  if dir == "" then
    dir = "."
  end
  local cmd = ":e " .. vim.fn.fnameescape(dir) .. "/"
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", true)
end, { desc = "Find file" })
map("n", "<leader>p", function()
  local path = vim.fs.joinpath(
    vim.env.HOME,
    ".local",
    "share",
    "nvim",
    "site",
    "pack",
    "core",
    "opt",
    "/"
  )
  vim.fn.feedkeys(":edit " .. vim.fn.fnameescape(path), "n")
  vim.schedule(function()
    vim.fn.wildtrigger()
  end)
end, { desc = "Find plugin file" })

--
-- Lsp & Diagnostics
--

-- Set default lsp config
vim.lsp.config("*", {
  root_markers = require("utils.fs").root_patterns,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  flags = {
    debounce_text_changes = 150,
  },
})

-- Enable lsps
vim.lsp.enable({
  "basedpyright",
  "bashls",
  "clangd",
  "gopls",
  "jsonls",
  "lua_ls",
  "markdown_oxide",
  "ts_ls",
  "vimls",
  "yamlls",
})

local icons = require("static.icons")
local text_signs = {
  [vim.diagnostic.severity.ERROR] = icons.Font.Diag.Error,
  [vim.diagnostic.severity.WARN] = icons.Font.Diag.Warn,
  [vim.diagnostic.severity.HINT] = icons.Font.Diag.Hint,
  [vim.diagnostic.severity.INFO] = icons.Font.Diag.Info,
}
vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = {
    text = text_signs,
    linehl = {
      [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
      [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
      [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
    },
  },
  virtual_text = {
    source = "if_many",
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
})

--
-- Filetypes
--

-- Filetypes
vim.filetype.add({
  pattern = {
    ["Dockerfile.*"] = "dockerfile",
  },
})

--
-- Local config
--

local local_config_dir =
  vim.fn.expand(vim.fs.joinpath(vim.env.HOME, ".config", "nvim-local"))
if vim.fn.isdirectory(local_config_dir) == 1 then
  vim.opt.rtp:append(local_config_dir)
end
