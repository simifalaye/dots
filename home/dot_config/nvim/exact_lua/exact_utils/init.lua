---@diagnostic disable: assign-type-mismatch

return setmetatable({
  asyncrpc = nil, ---@module 'utils.asyncrpc'
  fs = nil, ---@module 'utils.fs'
  hl = nil, ---@module 'utils.hl'
  json = nil, ---@module 'utils.json'
  lazy = nil, ---@module 'utils.lazy'
}, {
  __index = function(_, key)
    return require('utils.' .. key)
  end,
})
