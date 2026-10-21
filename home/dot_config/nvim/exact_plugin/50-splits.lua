local map = vim.keymap.set
local api = vim.api

--
-- Helper
--

-- Go to the previous window, or another window if there is no previous window.
local function switch_to_alt_win()
  local currwin = vim.fn.winnr()
  vim.cmd.wincmd("p")
  if vim.fn.winnr() == currwin then
    vim.cmd.wincmd("w")
  end
end

-- Toggle zoom on the current window.
local function zoom_toggle(count)
  if count > 0 then
    vim.cmd("normal! " .. count .. "|")
  end

  if vim.fn.winnr("$") == 1 then
    return
  end

  local restore_cmd = vim.fn.winrestcmd()

  vim.cmd.wincmd("|")
  vim.cmd.wincmd("_")

  if vim.t.zoom_restore ~= nil then
    vim.cmd(vim.t.zoom_restore)
    vim.t.zoom_restore = nil
  elseif vim.fn.winrestcmd() ~= restore_cmd then
    vim.t.zoom_restore = restore_cmd
  end
end

local function close_qflist()
  local altwin = vim.fn.winnr("#")
  vim.cmd.wincmd("c")

  if altwin > 0 then
    vim.cmd(altwin .. "wincmd w")
  end
end

--
-- Main
--

-- Autocommands
local augroup = vim.api.nvim_create_augroup("user.plugin.split", { clear = true })
api.nvim_create_autocmd("CmdwinEnter", {
  desc = "Map q to close the command-line window",
  group = augroup,
  callback = function(args)
    map("n", "q", "<C-w>c", {
      buffer = args.buf,
      nowait = true,
      silent = true,
      desc = "Close command-line window",
    })
  end,
})
api.nvim_create_autocmd("FileType", {
  desc = "Configure quickfix and location-list buffers",
  group = augroup,
  pattern = "qf",
  callback = function(args)
    local opts = { buffer = args.buf }
    map(
      "n",
      "q",
      close_qflist,
      vim.tbl_extend("force", opts, {
        nowait = true,
        silent = true,
        desc = "Close list and return to alternate window",
      })
    )
    vim.opt_local.list = false
  end,
})

-- Window
for _, mode in ipairs({ "n", "i", "t" }) do
  for key, direction in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
    map(mode, "<M-" .. key .. ">", "<C-\\><C-N><C-w><C-" .. direction .. ">", {
      silent = true,
      desc = "Move to " .. ({
        h = "left",
        j = "below",
        k = "above",
        l = "right",
      })[direction] .. " window",
    })
  end
end
map("n", "<M-\\>", function()
  if vim.v.count > 0 then
    vim.cmd.wincmd("w")
  else
    switch_to_alt_win()
  end
end, { silent = true, desc = "Switch to alternate window, or next window with a count" })
map("n", "<M-s>", "<cmd>split<cr>", {
  silent = true,
  desc = "Split window horizontally",
})
map("n", "<M-v>", "<cmd>vsplit<cr>", {
  silent = true,
  desc = "Split window vertically",
})
map("n", "<M-c>", "<cmd>close<cr>", {
  silent = true,
  desc = "Close window vertically",
})
map("n", "<M-=>", function()
  if vim.v.count > 0 then
    return ":<C-u>windo setlocal nowinfixheight nowinfixwidth<cr><C-w>="
  end
  return "@_<C-w>="
end, { expr = true, desc = "Equalize window sizes" })
map("n", "<M-z>", function()
  zoom_toggle(vim.v.count)
end, { desc = "Toggle window zoom" })

-- Tab
map("n", "<M-t>", "<cmd>tab split<cr>", {
  silent = true,
  desc = "Open current buffer in a new tab",
})
map("n", "<M-]>", "gt", {
  silent = true,
  desc = "Go to next tab",
})
map("n", "<M-[>", "gT", {
  silent = true,
  desc = "Go to previous tab",
})
map("n", "<M-x>", "<cmd>tabclose<cr>", {
  silent = true,
  desc = "Close current tab",
})
for i = 1, 9 do
  map({ "n", "x", "s", "o" }, "<M-" .. i .. ">", i .. "gt", {
    silent = true,
    desc = "Go to tab " .. i,
  })
end
map("n", "<M-}>", function()
  local target = vim.v.count > 0 and (vim.v.count - 1) or "+1"
  vim.cmd("tabmove " .. target)
end, { desc = "Move tab to position" })
map("n", "<M-{>", function()
  local target = vim.v.count > 0 and (vim.v.count - 1) or "-1"
  vim.cmd("tabmove " .. target)
end, { desc = "Move tab to position" })

-- Close/quit
map(
  "n",
  "ZZ",
  "v:count ? ':<c-u>xa!<cr>' : '@_ZZ'",
  { desc = "Write and quit window (all with count)", expr = true }
)
map(
  "n",
  "ZQ",
  "v:count ? ':<c-u>qa!<cr>' : '@_ZQ'",
  { desc = "Quit (all with count)", expr = true }
)
map("n", "ZT", "<cmd>tabclose<cr>", {
  silent = true,
  desc = "Close current tab",
})
