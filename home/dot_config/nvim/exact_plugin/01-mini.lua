local lazy = require("utils.lazy")

lazy.now(function()
  vim.pack.add({
    {
      src = "https://github.com/nvim-mini/mini.nvim",
      version = "stable",
    },
  })
end)

--
-- Now
--

lazy.now(function()
  local icons = require("mini.icons")
  icons.setup({
    use_file_extension = function(ext, _)
      local suf3, suf4 = ext:sub(-3), ext:sub(-4)
      return suf3 ~= "scm"
        and suf3 ~= "txt"
        and suf3 ~= "yml"
        and suf4 ~= "json"
        and suf4 ~= "yaml"
    end,
    file = {
      [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
      ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
    },
    filetype = {
      dotenv = { glyph = "", hl = "MiniIconsYellow" },
    },
  })
  lazy.later(icons.mock_nvim_web_devicons)
  lazy.later(icons.tweak_lsp_kind)
end)

lazy.now_if_args(function()
  local completion = require("mini.completion")
  -- Don't show 'Text' suggestions
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return completion.default_process_items(items, base, process_items_opts)
  end
  completion.setup({
    window = {
      info = {
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
      },
      signature = {
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
      },
    },
    lsp_completion = {
      source_func = "omnifunc",
      auto_setup = false,
      process_items = process_items,
    },
    mappings = {
      scroll_down = "<C-Down>",
      scroll_up = "<C-Up>",
    },
  })

  -- vim.lsp.on_type_formatting.enable()
  -- vim.o.autocomplete = true

  -- Set up LSP part of completion
  local augroup = vim.api.nvim_create_augroup("user.plugin.mini.completion", {})
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Setup mini completion omnifunc",
    group = augroup,
    pattern = "*",
    callback = function(args)
      vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
    end,
  })
  vim.api.nvim_create_autocmd("BufEnter", {
    desc = "Disable completion for prompt types",
    group = augroup,
    callback = function(args)
      if
        args.buf
        and vim.api.nvim_buf_is_valid(args.buf)
        and vim.bo[args.buf].buftype == "prompt"
      then
        -- TODO: Move to minibuffer.nvim
        vim.b.minicompletion_disable = true
      end
    end,
  })
end)

--
-- Later
--

lazy.later(function()
  require("mini.align").setup()
end)

lazy.later(function()
  local bufremove = require("mini.bufremove")
  bufremove.setup({})

  vim.keymap.set("n", "ZB", bufremove.delete, { desc = "Delete" })
end)

lazy.later(function()
  require("mini.cursorword").setup()
end)

lazy.later(function()
  local diff = require("mini.diff")
  diff.setup({
    view = {
      style = "sign",
      signs = {
        add = "┃",
        change = "┃",
        delete = "▁",
      },
    },
  })
  vim.keymap.set("n", "gh.", diff.toggle_overlay, { desc = "Toggle hunk overlay" })
end)

lazy.later(function()
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      fixme = { pattern = "FIXME", group = "MiniHipatternsFixme" },
      hack = { pattern = "HACK", group = "MiniHipatternsHack" },
      todo = { pattern = "TODO", group = "MiniHipatternsTodo" },
      note = { pattern = "NOTE", group = "MiniHipatternsNote" },
    },
  })
end)

lazy.later(function()
  local indentscope = require("mini.indentscope")
  indentscope.setup({
    draw = {
      delay = 0,
      animation = indentscope.gen_animation.none(),
    },
    symbol = "╎",
  })
end)

lazy.later(function()
  require("mini.operators").setup({
    -- Evaluate text and replace with output
    evaluate = {
      prefix = "g=",
    },
    -- Exchange text regions
    exchange = {
      prefix = "ge",
    },
    -- Multiply (duplicate) text
    multiply = {
      prefix = "gm",
    },
    -- Replace text with register
    replace = {
      prefix = "gr",
      -- Whether to reindent new text to match previous indent
      reindent_linewise = true,
    },
    -- Sort text
    sort = {
      prefix = "gs",
    },
  })
end)

lazy.later(function()
  local snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")
  local latex_patterns = { "latex/**/*.json", "**/latex.json" }
  local lang_patterns = {
    tex = latex_patterns,
    plaintex = latex_patterns,
    -- Recognize special injected language of markdown tree-sitter parser
    markdown_inline = { "markdown.json" },
  }
  local gen_loader = require("mini.snippets").gen_loader
  snippets.setup({
    snippets = {
      snippets.gen_loader.from_file(vim.fs.joinpath(config_path, "snippets", "all.json")),
      gen_loader.from_lang({ lang_patterns = lang_patterns }),
    },
  })
  snippets.start_lsp_server()
end)

lazy.later(function()
  require("mini.splitjoin").setup({})
end)

lazy.later(function()
  require("mini.surround").setup({})
end)

lazy.later(function()
  local trailspace = require("mini.trailspace")
  trailspace.setup({})

  local augroup = vim.api.nvim_create_augroup("user.plugin.mini.trailspace", {})
  vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Remove trailing whitespace on save",
    group = augroup,
    pattern = "*",
    callback = function()
      local ft = vim.bo.filetype
      local ignore = { "ruby", "perl", "markdown", "gitsendemail", "gitcommit" }
      for _, val in ipairs(ignore) do
        if string.match(ft, val) then
          return
        end
      end
      trailspace.trim()
    end,
  })
end)
