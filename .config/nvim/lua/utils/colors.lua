local log = require("utils.log")

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

M.apply_colorscheme = function(scheme)
  log.debug("Using colorscheme: " .. scheme)
  vim.cmd("colorscheme " .. scheme)
end

M.set_highlights = function(highlights)
  for group, spec in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

return M
