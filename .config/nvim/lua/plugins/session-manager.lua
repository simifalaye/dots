return {
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
    config = function ()
      require("session_manager").setup({
        autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
      })

      -- Setup keymaps
      local m = require("utils.map")
      m.group("<leader>s", "+session")
      m.nnoremap("<leader>sd", "<cmd>SessionManager delete_session<CR>", "Delete")
      m.nnoremap("<leader>sl", "<cmd>SessionManager load_session<CR>", "Load")
      m.nnoremap("<leader>sL", "<cmd>SessionManager load_last_session<CR>", "Load last")
      m.nnoremap("<leader>ss", "<cmd>SessionManager save_current_session<CR>", "Save")
    end,
  }
}
