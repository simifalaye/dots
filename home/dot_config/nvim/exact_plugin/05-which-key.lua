local lazy = require("utils.lazy")

lazy.later(function()
  vim.pack.add({
    {
      src = "https://github.com/folke/which-key.nvim",
      version = vim.version.range("*"),
    },
  })

  local opts = {
    delay = 500,
    icons = {
      rules = false,
    },
    disable = { filetypes = { "TelescopePrompt" } },
    spec = {
      {
        mode = { "n", "v" },
        { "<C-w>", group = "+Window" },
        { "[", group = "+Prev" },
        { "]", group = "+Next" },
        { "g", group = "+Goto" },
        { "gr", group = "+Lsp" },
        { "grw", group = "+Workspace" },
        { "<localleader>", group = "+Local" },
        { "<leader>", group = "+Global" },
        { "<leader>n", group = "+Notes" },
      },
    },
  }

  local ok, mb_wk = pcall(require, "minibuffer.integrations.which-key")
  if ok then
    mb_wk(opts)
  else
    require("which-key").setup(opts)
  end
end)
