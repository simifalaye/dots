local M = {}

M.def = {
  {
    "feline-nvim/feline.nvim",
    event = "VimEnter",
    requires = { "kyazdani42/nvim-web-devicons" },
  },
}

M.config = function()
  local feline = require("feline")
  local colors = require("conf.utils.colors")
  local c = colors.get_colors()
  local vi_mode_utils = require("feline.providers.vi_mode")

  local vi_mode_colors = {
    NORMAL = c.blue,
    INSERT = c.green,
    VISUAL = c.magenta,
    OP = c.magenta,
    BLOCK = c.acent,
    REPLACE = c.red,
    ["V-REPLACE"] = c.red,
    ENTER = c.cyan,
    MORE = c.cyan,
    SELECT = c.yellow,
    COMMAND = c.yellow,
    SHELL = c.green,
    TERM = c.green,
    NONE = c.grey,
  }

  -- Custom providers
  local provider = {
    spacer = function(n)
      return string.rep(" ", n or 1)
    end,
    bar_end = "▊",
  }
  -- Custom conditionals
  local conditional = {
    git_available = function()
      return vim.b.gitsigns_head ~= nil
    end,
    git_changed = function()
      local git_status = vim.b.gitsigns_status_dict
      return git_status
        and (git_status.added or 0)
            + (git_status.removed or 0)
            + (git_status.changed or 0)
          > 0
    end,
    has_filetype = function()
      return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        and vim.bo.filetype
        and vim.bo.filetype ~= ""
    end,
    bar_width = function(n)
      return function()
        return (
          vim.opt.laststatus:get() == 3 and vim.opt.columns:get()
          or vim.fn.winwidth(0)
        ) > (n or 80)
      end
    end,
  }

  feline.setup({
    theme = { bg = c.black_1, fg = c.fg },
    vi_mode_colors = vi_mode_colors,
    disable = {
      filetypes = {
        "^NvimTree$",
        "^neo%-tree$",
        "^dashboard$",
        "^Outline$",
        "^aerial$",
      },
    },
    components = {
      active = {
        -- Left
        {
          {
            provider = function()
              return provider.bar_end
            end,
            hl = function()
              local val = {
                name = vi_mode_utils.get_mode_highlight_name(),
                fg = vi_mode_utils.get_mode_color(),
              }
              return val
            end,
          },
          { provider = provider.spacer() },
          {
            provider = {
              name = "file_info",
              opts = {
                type = "unique",
                file_readonly_icon = "  ",
                file_modified_icon = "",
              },
            },
            hl = { fg = c.blue, style = "bold" },
          },
          { provider = provider.spacer() },
          {
            provider = "git_branch",
            hl = colors.get_hl_fg(
              "Conditional",
              { fg = c.purple_1, style = "bold" }
            ),
            icon = " ",
          },
          {
            provider = provider.spacer(),
            enabled = conditional.git_available(),
          },
          {
            provider = "git_diff_added",
            hl = colors.get_hl_fg("GitSignsAdd", { fg = c.green }),
            icon = "  ",
          },
          {
            provider = "git_diff_changed",
            hl = colors.get_hl_fg("GitSignsChange", { fg = c.yellow }),
            icon = "  ",
          },
          {
            provider = "git_diff_removed",
            hl = colors.get_hl_fg("GitSignsDelete", { fg = c.red }),
            icon = "  ",
          },
        },
        -- Middle
        {},
        -- Right
        {
          {
            provider = "diagnostic_errors",
            hl = colors.get_hl_fg("DiagnosticError", { fg = c.red }),
            icon = "  ",
          },
          {
            provider = "diagnostic_warnings",
            hl = colors.get_hl_fg("DiagnosticWarn", { fg = c.yellow }),
            icon = "  ",
          },
          {
            provider = "diagnostic_info",
            hl = colors.get_hl_fg("DiagnosticInfo", { fg = c.blue }),
            icon = "  ",
          },
          {
            provider = "diagnostic_hints",
            hl = colors.get_hl_fg("DiagnosticHint", { fg = c.cyan }),
            icon = "  ",
          },
          { provider = provider.spacer() },
          { provider = "position", hl = { fg = c.cyan, style = "bold" } },
          { provider = provider.spacer() },
          { provider = "line_percentage", hl = { style = "bold" } },
          { provider = provider.spacer() },
          { provider = "scroll_bar", hl = { fg = c.yellow, style = "bold" } },
          { provider = provider.spacer() },
          {
            provider = function()
              return provider.bar_end
            end,
            hl = function()
              local val = {
                name = vi_mode_utils.get_mode_highlight_name(),
                fg = vi_mode_utils.get_mode_color(),
              }
              return val
            end,
          },
        },
      },
    },
  })
end

return M
