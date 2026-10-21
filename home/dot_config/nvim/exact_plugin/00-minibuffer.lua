local lazy = require("utils.lazy")

vim.g.minibuffer = {
  dynamic_window_resize = true,
  cmd = {
    enabled = true,
    autotrigger = true,
    dynamic_height = false,
    max_height = 15,
  },
}

lazy.now(function()
  local local_path = vim.fs.joinpath(vim.env.HOME, "dev", "oss", "minibuffer.nvim")
  if require("utils.fs").dir_exists(local_path) then
    vim.opt.runtimepath:prepend(
      vim.fs.joinpath(vim.env.HOME, "dev", "oss", "minibuffer.nvim")
    )
    vim.cmd("runtime plugin/minibuffer.lua")
  else
    vim.pack.add({
      {
        src = "https://github.com/simifalaye/minibuffer.nvim",
      },
    })
  end

  local files_rg_opts = {
    "rg",
    "--no-config",
    "--files",
    "--hidden",
    "--color",
    "never",
    "-g",
    "!.git",
  }

  local minibuffer = require("minibuffer")

  vim.ui.select = require("minibuffer.builtin.ui_select")
  vim.ui.input = require("minibuffer.builtin.ui_input")

  vim.keymap.set("n", "<leader><CR>", function()
    minibuffer.resume(true)
  end, { desc = "Resume minibuffer" })

  -- <leader> + symbol
  vim.keymap.set("n", "<leader>;", function()
    require("minibuffer.builtin.history")({ type = "cmd" })
  end, { desc = "Find command history" })
  vim.keymap.set("n", "<leader>?", function()
    require("minibuffer.builtin.history")({ type = "search" })
  end, { desc = "Find command history" })
  vim.keymap.set("n", "<leader>'", function()
    require("minibuffer.builtin.marks")()
  end, { desc = "Find mark" })
  vim.keymap.set(
    "n",
    "<leader>/",
    require("minibuffer.builtin.live-grep"),
    { desc = "Find text" }
  )
  vim.keymap.set(
    "n",
    "<leader>b",
    require("minibuffer.builtin.buffers"),
    { desc = "Find Buffer" }
  )
  vim.keymap.set("n", "<leader>c", function()
    require("minibuffer.builtin.files")({
      rg_opts = files_rg_opts,
      cwd = vim.fs.joinpath(
        vim.fs.joinpath(vim.env.HOME, ".local", "share", "chezmoi"),
        ".dotfiles"
      ),
    })
  end, { desc = "Find config file" })
  vim.keymap.set("n", "<leader>d", function()
    require("minibuffer.builtin.diagnostics")({ scope = "buffer" })
  end, { desc = "Find diagnostic" })
  vim.keymap.set("n", "<leader>D", function()
    require("minibuffer.builtin.diagnostics")({ scope = "workspace" })
  end, { desc = "Find diagnostics (workspace)" })
  vim.keymap.set("n", "<leader>f", function()
    require("minibuffer.builtin.files")({
      rg_opts = files_rg_opts,
    })
  end, { desc = "Find file" })
  vim.keymap.set(
    "n",
    "<leader>F",
    require("minibuffer.builtin.git-files"),
    { desc = "Find git file" }
  )
  vim.keymap.set("n", "<leader>l", function()
    require("minibuffer.builtin.list")({ type = "loclist" })
  end, { desc = "Find loclist item" })
  vim.keymap.set(
    "n",
    "<leader>m",
    require("minibuffer.builtin.manpages"),
    { desc = "Find manpage" }
  )
  vim.keymap.set("n", "<leader>o", function()
    require("minibuffer.builtin.oldfiles")({ cwd = vim.fn.getcwd() })
  end, { desc = "Find oldfiles (cwd)" })
  vim.keymap.set(
    "n",
    "<leader>O",
    require("minibuffer.builtin.oldfiles"),
    { desc = "Find oldfiles" }
  )
  vim.keymap.set("n", "<leader>q", function()
    require("minibuffer.builtin.list")({ type = "quickfix" })
  end, { desc = "Find quickfix item" })
end)
