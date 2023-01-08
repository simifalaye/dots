return {
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = {
      options = {
        component_separators = "|",
        section_separators = "",
        icons_enabled = true,
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "lazy" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      tabline = {
        lualine_a = { "buffers" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { "tabs" },
      },
    },
  },
}
