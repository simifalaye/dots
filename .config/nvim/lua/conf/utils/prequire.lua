--- Require a module safely
---@param module string
---@return any: module or nil if error
return function(module)
  local ok, result = pcall(require, module)
  if ok then
    return result
  end
  return nil
end
