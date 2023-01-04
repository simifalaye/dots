return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = { "Neotree" },
    init = function()
      -- Setup keybinds
      local m = require("conf.utils.map")
      m.nnoremap("-", "<cmd>Neotree toggle<CR>", "Explorer")
      m.nnoremap("_", "<cmd>Neotree reveal<CR>", "Open file in explorer")
    end,
    config = function()
      local tree = require("neo-tree")

      -- Setup plugin
      tree.setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_diagnostics = false,
        follow_current_file = false,
        default_component_configs = {
          indent = {
            padding = 0,
            with_expanders = false,
          },
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            default = "",
          },
          git_status = {
            symbols = {
              added = "",
              deleted = "",
              modified = "",
              renamed = "➜",
              untracked = "★",
              ignored = "◌",
              unstaged = "✗",
              staged = "✓",
              conflict = "",
            },
          },
        },
        window = {
          width = 25,
          mappings = {
            ["l"] = "open",
            ["h"] = "close_node",
          },
        },
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_by_name = {
              ".DS_Store",
              "thumbs.db",
              "node_modules",
              "__pycache__",
            },
          },
          follow_current_file = false,
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = true,
        },
        git_status = {
          window = {
            position = "float",
          },
        },
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function(_)
              vim.opt_local.signcolumn = "auto"
            end,
          },
        },
      })
    end,
  },
}