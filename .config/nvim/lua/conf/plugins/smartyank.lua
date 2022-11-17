local M = {}

M.def = {
  {
    "ibhagwan/smartyank.nvim",
    event = "BufWinEnter",
  },
}

M.config = function()
  require("smartyank").setup({
    highlight = {
      enabled = true,         -- highlight yanked text
      higroup = "IncSearch",  -- highlight group of yanked text
      timeout = 300,         -- timeout for clearing the highlight
    },
    clipboard = {
      enabled = true
    },
    tmux = {
      enabled = true,
      -- remove `-w` to disable copy to host client's clipboard
      cmd = { 'tmux', 'set-buffer', '-w' }
    },
    osc52 = {
      enabled = true,
      ssh_only = false,        -- OSC52 yank also in local sessions
      silent = false,         -- false to disable the "n chars copied" echo
      echo_hl = "Directory",  -- highlight group of the echo message
    }
  })
end

return M
