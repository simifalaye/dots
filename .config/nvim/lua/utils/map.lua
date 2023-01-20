local api = vim.api
local log = require("utils.log")

_G._store["keymaps"] = _G._store["keymaps"] or {}
local map_store = _G._store["keymaps"]

local M = {}

-- Src: https://github.com/akinsho/dotfiles
local function make_mapper(mode, o)
  -- copy the opts table as extends will mutate the opts table passed in otherwise
  local parent_opts = vim.deepcopy(o)
  ---Create a mapping
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts? string|table options table or string description
  ---@param opts_tbl? table use if providing description in third arg
  return function(lhs, rhs, opts, opts_tbl)
    local desc = nil
    if type(opts) == "string" then
      desc = opts
      opts = opts_tbl
    end
    opts = opts or {}
    if desc then
      opts.desc = desc
    end
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("keep", opts, parent_opts))
    if opts.buffer == nil then
      table.insert(map_store, { mode = mode, lhs = lhs })
    end
    log.debug("Keymap {%s, %s, %s}", mode, lhs, rhs)
  end
end

local function multimap(target)
  ---Create a mapping for multiple modes
  ---@param modes string|table
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts? string|table options table or string description
  ---@param opts_tbl? table use if providing description in third arg
  return function(modes, lhs, rhs, opts, opts_tbl)
    if type(modes) == "string" then
      modes = { modes }
    elseif modes then
      modes = vim.deepcopy(modes)
    else
      modes = {}
    end
    for _, m in ipairs(modes) do
      M[m .. target](lhs, rhs, opts, opts_tbl)
    end
  end
end

local map_opts = { remap = true, silent = true }
local noremap_opts = { silent = true }

-- Mapping helper functions
M.map = multimap("map")
M.nmap = make_mapper("n", map_opts)
M.xmap = make_mapper("x", map_opts)
M.vmap = make_mapper("v", map_opts)
M.imap = make_mapper("i", map_opts)
M.omap = make_mapper("o", map_opts)
M.tmap = make_mapper("t", map_opts)
M.smap = make_mapper("s", map_opts)
M.cmap = make_mapper("c", { noremap = false, silent = false })
M.noremap = multimap("noremap")
M.nnoremap = make_mapper("n", noremap_opts)
M.xnoremap = make_mapper("x", noremap_opts)
M.vnoremap = make_mapper("v", noremap_opts)
M.inoremap = make_mapper("i", noremap_opts)
M.onoremap = make_mapper("o", noremap_opts)
M.tnoremap = make_mapper("t", noremap_opts)
M.snoremap = make_mapper("s", noremap_opts)
M.cnoremap = make_mapper("c", { noremap = true, silent = false })

--- Register a which-key group name
---@param prefix string
---@param name string
M.group = function(prefix, name)
  if not prefix or not name then
    return
  end
  local wk = _G.prequire("which-key")
  if wk then
    wk.register({ [prefix] = { name = name } })
    log.debug("Key Group {%s, %s}", prefix, name)
  end
end

--- Unmap all user keymappings
M.unmap_all = function()
  -- Unbind keys
  for _, v in pairs(map_store) do
    if v.mode and v.lhs then
      local _, _ = pcall(api.nvim_del_keymap, v.mode, v.lhs)
      log.debug("Unmap {%s, %s}", v.mode, v.lhs)
    end
  end
  log.debug("All global user keys have been unbound")
  -- Reset stored keys
  map_store = {}
end

return M
