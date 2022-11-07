--[[

Neovim inint file
Nvim version: 0.7.0+
Maintainer: simifalaye

--]]
local log = require("conf.utils.log")

-- Globals
-- ==========

_G._store = _G._store or {}

--- Inspect the contents of an object very quickly
--- ex. P({1,2,3})
--- @vararg any
--- @return any
_G.P = function(...)
  local objects, v = {}, nil
  for i = 1, select("#", ...) do
    v = select(i, ...)
    table.insert(objects, vim.inspect(v))
  end
  print(table.concat(objects, "\n"))
  return ...
end

-- Init
-- =======

-- Setup loading optimizer
local impatient_ok, impatient = pcall(require, "impatient")
if impatient_ok then
  impatient.enable_profile()
end

-- Load modules in order
for _, module in ipairs({
  "conf.plugins",
  "conf.core.options",
  "conf.core.commands",
  "conf.core.events",
  "conf.core.keymaps",
  "conf.core.theme",
}) do
  local status_ok, fault = pcall(require, module)
  if not status_ok then
    log.error("Failed to load: " .. module .. "\n\n" .. fault)
  end
end
