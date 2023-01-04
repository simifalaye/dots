return {
  {
    "RRethy/nvim-base16",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      local log = require("conf.utils.log")
      local base16 = require("base16-colorscheme")

      local colorscheme = vim.env.BASE16_THEME
      local bcolors = base16.colorschemes[colorscheme]
      if not colorscheme or colorscheme == "" or not bcolors then
        log.debug("Using default colorscheme instead of: " .. colorscheme)
        colorscheme = "default-dark"
        bcolors = base16.colorscheme[colorscheme]
      end
      colorscheme = "base16-" .. colorscheme

      -- load the colorscheme here
      vim.cmd("colorscheme " .. colorscheme)
    end,
  },
}
