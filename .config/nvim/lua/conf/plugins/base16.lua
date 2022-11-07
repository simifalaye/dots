local M = {}

M.def = {
  {
    "RRethy/nvim-base16",
  },
}

M.init = function()
  local prequire = require("conf.utils.prequire")
  local base16 = prequire("base16-colorscheme")

  -- Load the colorscheme early so that it is set for all plugins
  if base16 then
    M.load_colors(base16)
  end
end

M.config = function()
  if not M.loaded then
    local base16 = require("base16-colorscheme")
    M.load_colors(base16)
  end
end

M.loaded = false

M.load_colors = function(base16)
  local colors = require("conf.utils.colors")
  local log = require("conf.utils.log")

  -- Get colorscheme colors
  local colorscheme = vim.env.BASE16_THEME
  local bcolors = base16.colorschemes[colorscheme]
  if not colorscheme or colorscheme == "" or not bcolors then
    log.debug("Using default colorscheme instead of: " .. colorscheme)
    colorscheme = "default-dark"
    bcolors = base16.colorscheme[colorscheme]
  end
  colorscheme = "base16-" .. colorscheme

  -- Set colorscheme
  colors.set_scheme(colorscheme)
  colors.apply_colorscheme()

  -- Set statusline colors
  colors.set_colors({
    fg = bcolors.base05,
    bg = bcolors.base00,
    red = bcolors.base08,
    green = bcolors.base0B,
    yellow = bcolors.base0A,
    blue = bcolors.base0D,
    magenta = bcolors.base0E,
    cyan = bcolors.base0C,
    white = bcolors.base05,
    white_1 = bcolors.base07,
    grey = bcolors.base02,
    grey_1 = bcolors.base03,
    black = bcolors.base00,
    black_1 = bcolors.base01,
    accent = bcolors.base09,
    accent_1 = bcolors.base0F,
  })
  M.loaded = true
end

return M
