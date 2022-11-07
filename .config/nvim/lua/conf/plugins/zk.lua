local M = {}

M.def = {
  {
    "mickael-menu/zk-nvim",
    after = "telescope.nvim",
  },
}

M.config = function()
  local prequire = require("conf.utils.prequire")
  local tl = prequire("telescope")

  -- Setup plugin
  require("zk").setup({
    -- can be "telescope", "fzf" or "select" (`vim.ui.select`)
    -- it's recommended to use "telescope" or "fzf"
    picker = tl and "telescope" or "select",

    lsp = {
      -- `config` is passed to `vim.lsp.start_client(config)`
      config = {
        cmd = { "zk", "lsp" },
        name = "zk",
        on_attach = function(_, bufnr)
          local m = require("conf.utils.map")
          local o = { buffer = bufnr, silent = false }
          ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
          if require("zk.util").notebook_root(vim.fn.expand("%:p")) ~= nil then
            m.nnoremap(
              "<CR>",
              "<Cmd>lua vim.lsp.buf.definition()<CR>",
              "Open link",
              o
            )
            m.nnoremap(
              "<leader>zn",
              "<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
              "New", -- same dir as curr buffer
              o
            )
            m.vnoremap(
              "<leader>znt",
              ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>",
              "New title with selection",
              o
            )
            m.vnoremap(
              "<leader>znc",
              [[ :'<,'>ZkNewFromContentSelection {
              dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>]],
              "New content with selection",
              o
            )

            m.nnoremap(
              "<leader>zb",
              "<Cmd>ZkBacklinks<CR>",
              "Show backlinks",
              o
            )
            m.nnoremap("<leader>zl", "<Cmd>ZkLinks<CR>", "Show links", o)
            m.nnoremap(
              "<leader>zz",
              "<Cmd>lua vim.lsp.buf.hover()<CR>",
              "Preview linked note",
              o
            )
            m.vnoremap(
              "<leader>za",
              ":'<,'>lua vim.lsp.buf.range_code_action()<CR>",
              "Code action",
              o
            )
          end
        end,
        -- etc, see `:h vim.lsp.start_client()`
      },

      -- automatically attach buffers in a zk notebook that match the given filetypes
      auto_attach = {
        enabled = true,
        filetypes = { "markdown" },
      },
    },
  })

  -- Setup keybinds
  local m = require("conf.utils.map")
  local opts = { silent = false }
  m.group("<leader>z", "+zk")
  m.nnoremap(
    "<leader>zf",
    "<Cmd>ZkNotes { sort = { 'modified' }, "
      .. "match = vim.fn.input('Search: ') }<CR>",
    "Find with query",
    opts
  )
  m.vnoremap("<leader>zf", ":'<,'>ZkMatch<CR>", "Find selection", opts)
  m.nnoremap("<leader>zL", "<Cmd>ZkNew { dir = 'log' }<CR>", "Daily log", opts)
  m.nnoremap(
    "<leader>zn",
    "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>",
    "New",
    opts
  )
  m.nnoremap(
    "<leader>zo",
    "<Cmd>ZkNotes { sort = { 'modified' } }<CR>",
    "Open",
    opts
  )
  m.nnoremap("<leader>zt", "<Cmd>ZkTags<CR>", "Tags", opts)
end

return M
