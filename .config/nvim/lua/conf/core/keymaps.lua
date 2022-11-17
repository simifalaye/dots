local m = require("conf.utils.map")

-- Map leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Multi mode
-------------

-- Move up/down by visual line
m.noremap(
  { "n", "x", "o" },
  "j",
  'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
  { expr = true }
)
m.noremap(
  { "n", "x", "o" },
  "k",
  'v:count || mode(1)[0:1] == "no" ? "k" : "gk"',
  { expr = true }
)

-- Save and quit
m.noremap({ "n", "i", "v" }, "<C-s>", "<Esc>:update<CR>", "Save buffer")
m.noremap({ "n", "i", "v" }, "<C-q>", "<Esc>:confirm qa<CR>", "Quit nvim")
m.noremap({ "n", "i", "v" }, "<C-x>", "<Esc>:q<CR>", "Quit window")

-- Normal mode
--------------

-- Remaps
m.nnoremap("<Esc>", ":noh<CR><Esc>")
m.nnoremap("/", "ms/\\v", { silent = false })
m.nnoremap("?", "ms?\\v", { silent = false })
m.nnoremap("n", "nzzzv")
m.nnoremap("N", "Nzzzv")
m.nnoremap("p", "p`[v`]=", "Paste & format")
m.nnoremap("Q", "@q", "Run q macro")

-- (<C-t> tab) namespace
m.group("<C-t>", "+tab")
m.nnoremap("<C-t>c", ":tabclose<CR>", "Close")
m.nnoremap("<C-t>e", ":tabedit<CR>", "Edit")
m.nnoremap("<C-t>t", ":tabnext #<CR>", "Alt")
m.nnoremap("<C-t>n", ":tabnext<CR>", "Next")
m.nnoremap("<C-t>p", ":tabprev<CR>", "Prev")
m.nnoremap("<C-t>o", ":tabonly<CR>", "Only")

-- (g) namespace
m.nmap("g-", "yyp^v$r-Vk", "Underline -")
m.nmap("g=", "yyp^v$r=Vk", "Underline =")
m.nnoremap(
  "gm",
  [[<cmd>set nomore<bar>40messages<bar>set more<CR>]],
  "Show message history"
)
m.nnoremap(
  "gp",
  "'`[' . strpart(getregtype(), 0, 1) . '`]'",
  "Select last changed text",
  { expr = true }
)
m.nnoremap("gx", ":! chmod +x %<CR>", "Make file executable")

-- ([/]) namespace
m.nnoremap(
  "[<space>",
  ":<C-u>put!=repeat([''],v:count)<bar>']+1<CR>",
  "Add lines above"
)
m.nnoremap(
  "]<space>",
  ":<C-u>put =repeat([''],v:count)<bar>'[-1<CR>",
  "Add lines below"
)
m.nnoremap("]b", ":bn<CR>", "Buffer next")
m.nnoremap("[b", ":bp<CR>", "Buffer prev")
m.nnoremap("]e", ":m .+1<CR>==", "Exchange line down")
m.nnoremap("[e", ":m .-2<CR>==", "Exchange line up")
m.nnoremap("]q", ":cnext<CR>zz", "Quickfix next")
m.nnoremap("[q", ":cprev<CR>zz", "Quickfix prev")
m.nnoremap("]l", ":lnext<cr>zz", "Loclist next")
m.nnoremap("[l", ":lprev<cr>zz", "Loclist prev")
m.nnoremap("]c", ":GotoConflict next<CR>", "Conflict next")
m.nnoremap("[c", ":GotoConflict prev<CR>", "Conflict prev")
m.group("[o", "+set")
m.nnoremap("[oc", ":set cursorline<CR>", "cursorline")
m.nnoremap("[or", ":set relativenumber<CR>", "relativenumber")
m.nnoremap("[os", ":set spell<CR>", "spell")
m.nnoremap("[ot", ":set expandtab<CR>", "expandtab")
m.group("]o", "+unset")
m.nnoremap("]oc", ":set nocursorline<CR>", "cursorline")
m.nnoremap("]or", ":set norelativenumber<CR>", "relativenumber")
m.nnoremap("]os", ":set nospell<CR>", "spell")
m.nnoremap("]ot", ":set noexpandtab<CR>", "expandtab")
m.nnoremap("]t", ":tabprev<CR>", "Tab next")
m.nnoremap("[t", ":tabnext<CR>", "Tab prev")

-- Search and Replace
-- 'c.' for word, 'c>' for WORD
-- 'c.' in visual mode for selection
m.nmap(
  "c.",
  [[:%s/\<<C-r><C-w>\>//g<Left><Left>]],
  { desc = "search and replace word under cursor" }
)
m.nmap(
  "c>",
  [[:%s/\V<C-r><C-a>//g<Left><Left>]],
  { desc = "search and replace WORD under cursor" }
)

-- Leader
m.nnoremap("<leader><leader>", "<C-^>", "Last buffer")
m.nnoremap("<leader>c", ":BufDel 0<CR>", "Close buffer")
m.nnoremap("<leader>q", ":ToggleList c<CR>", "Toggle Quickfix")
m.nnoremap("<leader>R", ":Reload<CR>", "Reload config")
-- m.nnoremap("<leader>x", ":BufDel 1<CR>", "Exit buffer (wipe)")

-- Visual/select/operator mode
------------------------------

-- Remaps
m.vnoremap(".", ":norm.<CR>") -- visual dot repeat
m.vnoremap("$", "g_")
m.vnoremap("<", "<gv")
m.vnoremap(">", ">gv")
m.vnoremap("*", [[y/<C-R>"<CR>]]) -- visual search
m.vnoremap("#", [[y?<C-R>"<CR>]]) -- visual search
m.vnoremap("y", "ygv<Esc>") -- keep cursor
m.vnoremap("Q", ":norm @q<CR>", "Run Q silent", { silent = false })
m.xnoremap("p", "pgvy") -- paste no copy

-- Text objects
m.xnoremap("il", "g_o0", "in line")
m.xnoremap("al", "$o0", "a line")
m.xnoremap("ie", ":<C-u>normal! G$Vgg0<CR>", "in entire")
m.onoremap("il", ":normal vil<CR>", "in line")
m.onoremap("al", ":normal val<CR>", "a line")
m.onoremap("ie", ":<C-u>normal! GVgg<CR>", "in entire")

-- ([/]) namespace
m.vnoremap("]e", ":move'>+<CR>='[gv", "Exchange line down")
m.vnoremap("[e", ":move-2<CR>='[gv", "Exchange line up")
vim.cmd([[
  function! ExecuteMacroOverVisualRange()
    echo "@".getcmdline()
    execute ":'<,'>normal @".nr2char(getchar())
  endfunction
]])
m.xnoremap(
  "@",
  ":<C-u>call ExecuteMacroOverVisualRange()<CR>",
  "Q macro over range",
  { silent = false }
)

-- Insert mode
--------------

-- Readline
m.inoremap("<C-a>", "<C-o>^")
m.inoremap(
  "<C-e>",
  [[col('.')>strlen(getline('.'))<bar><bar>pumvisible()?"\<Lt>C-E>":"\<Lt>End>"]],
  { expr = true }
)
m.inoremap(
  "<C-b>",
  [[getline('.')=~'^\s*$'&&col('.')>strlen(getline('.'))?"0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"]],
  { expr = true }
)
m.inoremap(
  "<C-f>",
  [[col('.')>strlen(getline('.'))?"\<Lt>C-F>":"\<Lt>Right>"]],
  { expr = true }
)
m.inoremap(
  "<C-d>",
  [[col('.')>strlen(getline('.'))?"\<Lt>C-D>":"\<Lt>Del>"]],
  { expr = true }
)

-- Command mode
---------------

-- Readline
m.cnoremap("<c-x><c-a>", "<C-a>", "Expand globs")
m.cnoremap("<C-a>", "<Home>")
m.cnoremap("<C-e>", "<End>")
m.cnoremap("<C-b>", "<Left>")
m.cnoremap("<C-d>", "<Del>")
m.cnoremap(
  "<C-k>",
  [[<C-\>e getcmdpos() == 1 ? '' : getcmdline()[:getcmdpos() - 2]<CR>]]
)
m.cnoremap(
  "<C-f>",
  [[getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"]],
  { expr = true }
)
m.cnoremap("<C-y>", [[pumvisible() ? "\<C-Y>" : "\<C-R>-"]], { expr = true })

-- File/dir name accessors
m.cnoremap(
  "<M-,>",
  "<C-r>=fnameescape(expand('%'))<cr>",
  "Insert file path",
  { silent = false }
)
m.cnoremap(
  "<M-.>",
  "<C-r>=fnameescape(expand('%:p:h'))<cr>/",
  "Insert dir path",
  { silent = false }
)
