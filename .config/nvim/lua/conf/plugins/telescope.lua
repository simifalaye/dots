local utils = require("conf.utils")

local M = {}

M.def = {
  {
    "nvim-telescope/telescope.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
      },
    },
  },
}

M.config = function()
  local telescope = require("telescope")
  local actions = require("telescope.actions")

  -- Setup plugin
  telescope.setup({
    defaults = {
      path_display = { "truncate" },
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          prompt_position = "top",
          preview_width = 0.55,
          results_width = 0.8,
        },
        vertical = {
          mirror = false,
        },
        width = 0.87,
        height = 0.80,
        preview_cutoff = 120,
      },
      mappings = {
        i = {
          ["<Down>"] = actions.cycle_history_next,
          ["<Up>"] = actions.cycle_history_prev,
          ["<Esc>"] = actions.close,
          ["<C-c>"] = actions.close,
        },
      },
    },
    pickers = {
      buffers = {
        theme = "dropdown",
        previewer = false,
        sort_lastused = true,
      },
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = false, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        -- the default case_mode is "smart_case"
      },
    },
  })

  -- Load extensions
  telescope.load_extension("fzf")

  -- Setup keymaps
  local m = require("conf.utils.map")
  m.nnoremap("<C-p>", "<cmd>Telescope find_files<CR>", "Find Files")
  m.nnoremap(
    "<leader>;",
    "<cmd>Telescope buffers show_all_buffers=true<CR>",
    "Find Buffer"
  )
  m.nnoremap("<leader>:", "<cmd>Telescope command_history<CR>", "Find CmdHist")
  m.nnoremap("<leader>,", "<cmd>Telescope oldfiles<CR>", "Find Recent")
  m.nnoremap("<leader>.", "<cmd>Telescope resume<CR>", "Find resume")
  m.nnoremap("<leader>/", "<cmd>Telescope live_grep<CR>", "Find text")
  m.group("<leader>f", "+find")
  m.nnoremap("<leader>f?", "<cmd>Telescope builtin<cr>", "Builtin")
  m.nnoremap("<leader>f/", "<cmd>Telescope search_history<cr>", "SearchHist")
  m.nnoremap("<leader>f'", "<cmd>Telescope registers<cr>", "Registers")
  m.nnoremap("<leader>fa", "<cmd>Telescope autocommands<CR>", "Autocommands")
  m.nnoremap(
    "<leader>fb",
    "<cmd>Telescope current_buffer_fuzzy_find<CR>",
    "(in) Buffer"
  )
  m.nnoremap("<leader>fc", "<cmd>Telescope commands<CR>", "Commands")
  m.nnoremap("<leader>fd", function()
    assert(
      utils.file_exists(utils.dotpath()),
      "Dir does not exist: " .. utils.dotpath()
    )
    require("telescope.builtin").find_files({
      prompt_title = "Dotfiles",
      cwd = utils.dotpath(),
      hidden = true,
      find_command = { "git", "ls-files" },
    })
  end, "Dotfiles")
  m.nnoremap("<leader>ff", "<cmd>Telescope find_files hidden=true no_ignore=true<CR>", "Files (all)")
  m.nnoremap("<leader>fh", "<cmd>Telescope help_tags<CR>", "Help")
  m.nnoremap("<leader>fH", "<cmd>Telescope highlights<CR>", "Highlights")
  m.nnoremap("<leader>fk", "<cmd>Telescope keymaps<CR>", "Keymaps")
  m.nnoremap("<leader>fm", "<cmd>Telescope marks<CR>", "Marks")
  m.nnoremap("<leader>fM", "<cmd>Telescope man_pages<CR>", "Man Pages")
  m.nnoremap("<leader>fo", "<cmd>Telescope vim_options<CR>", "Options")
  m.nnoremap("<leader>fq", "<cmd>Telescope quickfix<CR>", "Quickfix")
  m.nnoremap("<leader>fs", function()
    require("telescope.builtin").lsp_document_symbols({
      symbols = {
        "Class",
        "Function",
        "Method",
        "Constructor",
        "Interface",
        "Module",
      },
    })
  end, "Symbol [LSP]")
  m.group("<leader>fg", "+git")
  m.nnoremap("<leader>fgb", "<cmd>Telescope git_branches<CR>", "Branches")
  m.nnoremap("<leader>fgc", "<cmd>Telescope git_commits<CR>", "Commits")
  m.nnoremap("<leader>fgo", "<cmd>Telescope git_bcommits<CR>", "Commits (buf)")
  m.nnoremap("<leader>fgs", "<cmd>Telescope git_status<CR>", "Status")

  -- Highlights
  local colors = require("conf.utils.colors")
  local c = colors.get_colors()
  colors.set_highlights({
    TelescopeBorder = { fg = c.fg },
    TelescopePromptBorder = { fg = c.fg },
    TelescopePromptNormal = { fg = c.fg, bg = c.bg },
    TelescopePromptPrefix = { fg = c.blue },
    TelescopeNormal = { fg = c.fg, bg = c.bg },
    TelescopePreviewTitle = { fg = c.magenta },
    TelescopePromptTitle = { fg = c.blue },
    TelescopeResultsTitle = { fg = c.yellow },
    TelescopeSelection = { bg = c.grey_1 },
    TelescopeResultsDiffAdd = { fg = c.none, bg = c.green },
    TelescopeResultsDiffChange = { fg = c.none, bg = c.yellow },
    TelescopeResultsDiffDelete = { fg = c.none, bg = c.red },
  })
end

return M
