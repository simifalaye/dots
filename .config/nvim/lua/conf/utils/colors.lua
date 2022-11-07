local log = require("conf.utils.log")

_G._store["colors"] = _G._store["colors"] or { colors = nil, scheme = nil }
local colors_store = _G._store["colors"]

local M = {}

local function hl_by_name(name)
  return string.format(
    "#%06x",
    vim.api.nvim_get_hl_by_name(name.group, true)[name.prop]
  )
end

local function hl_prop(group, prop)
  local status_ok, color = pcall(hl_by_name, { group = group, prop = prop })
  return status_ok and color or nil
end

M.get_hl_group = function(hlgroup, base)
  return vim.tbl_deep_extend(
    "force",
    base or {},
    { fg = hl_prop(hlgroup, "foreground"), bg = hl_prop(hlgroup, "background") }
  )
end

M.get_hl_fg = function(hlgroup, base)
  return vim.tbl_deep_extend(
    "force",
    base or {},
    { fg = hl_prop(hlgroup, "foreground") }
  )
end

M.get_colors = function()
  return colors_store.colors
    or {
      none = "NONE",
      fg = hl_prop("Normal", "foreground"),
      bg = hl_prop("Normal", "background"),
      red = hl_prop("WarningMsg", "foreground"),
      green = hl_prop("Question", "foreground"),
      yellow = hl_prop("LineNr", "foreground"),
      blue = hl_prop("EndOfBuffer", "foreground"),
      magenta = hl_prop("Title", "foreground"),
      cyan = hl_prop("Directory", "foreground"),
      white = hl_prop("Normal", "foreground"),
      white_1 = hl_prop("ModeMsg", "foreground"),
      grey = hl_prop("SignColumn", "background"),
      grey_1 = hl_prop("CursorColumn", "background"),
      black = hl_prop("Normal", "background"),
      black_1 = hl_prop("Normal", "background"),
      accent = hl_prop("Tag", "foreground"),
      accent_1 = hl_prop("Comment", "foreground"),
    }
end

M.set_colors = function(value)
  colors_store.colors =
    vim.tbl_deep_extend("force", colors_store.colors or {}, value or {})
end

M.get_scheme = function()
  return colors_store.scheme or "default"
end

M.set_scheme = function(value)
  colors_store.scheme = value
end

M.apply_colorscheme = function()
  local scheme = M.get_scheme()
  log.debug("Using colorscheme: " .. scheme)
  vim.cmd("colorscheme " .. scheme)
end

M.set_highlights = function(highlights)
  for group, spec in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

return M
