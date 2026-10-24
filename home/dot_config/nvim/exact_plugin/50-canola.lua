local lazy = require("utils.lazy")

vim.g.canola = {
  columns = { "type", "permissions", "size", "mtime", "icon" },
  watch = true,
  hidden = { enabled = true, patterns = { "^%.%." }, always = {} }, -- hide files that start with ".."
  confirm = "delete",
  save = "auto",
  delete = { wipe = true },
  win = {
    number = false,
    relativenumber = false,
    signcolumn = "no",
    foldcolumn = "0",
    statuscolumn = "",
  },
}
vim.g.canola_ssh = {}
vim.g.canola_trash = {}

lazy.now_if_args(function()
  vim.pack.add({
    { src = "https://forge.barrettruth.com/barrettruth/canola.nvim", version = "canola" },
    { src = "https://forge.barrettruth.com/barrettruth/canola-collection" },
  })

  -- Set keymaps
  vim.keymap.set("n", "-", "<cmd>Canola<CR>", { desc = "Open parent directory" })
  vim.keymap.set("n", "_", function()
    vim.cmd("Canola " .. vim.fs.root(0, require("utils.fs").root_patterns))
  end, { desc = "Open root directory" })
end)
