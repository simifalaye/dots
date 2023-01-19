return {
  {
    "Shatur/neovim-session-manager",
    cmd = { "SessionManager" },
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
    init = function()
      -- Setup keymaps
      local m = require("utils.map")
      m.group("<leader>s", "+session")
      m.nnoremap(
        "<leader>sd",
        "<cmd>SessionManager delete_session<CR>",
        "Delete"
      )
      m.nnoremap(
        "<leader>sl",
        "<cmd>SessionManager load_current_dir_session<CR>",
        "Load current dir"
      )
      m.nnoremap(
        "<leader>sL",
        "<cmd>SessionManager load_last_session<CR>",
        "Load last"
      )
      m.nnoremap(
        "<leader>sp",
        "<cmd>SessionManager load_session<CR>",
        "Pick (load)"
      )
      m.nnoremap(
        "<leader>ss",
        "<cmd>SessionManager save_current_session<CR>",
        "Save"
      )
    end,
    config = function()
      require("session_manager").setup({
        -- Disable auto{save, load}, force manual
        autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
        autosave_last_session = false,
        -- autosave_ignore_filetypes = {
        --   "gitcommit",
        --   "fern",
        --   "NvimTree",
        --   "netrw",
        --   "neo-tree",
        -- },
      })
    end,
  },
}
