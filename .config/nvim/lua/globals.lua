_G._store = _G._store or {}

-- Path separator based on os
_G.path_sep = vim.loop.os_uname().version:match("Windows") and "\\" or "/"

-- WSL deployment
_G.is_wsl = (function()
  local uname = vim.fn.substitute(vim.fn.system('uname'),'\n','','')
  if uname == "Linux" then
    local s = string.match(vim.fn.readfile("/proc/version")[1], "microsoft")
    if string.match(s, "microsoft") then
      return true
    end
    return false
  end
end)()

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

--- Require a module safely
---@param module string
---@return any: module or nil if error
_G.prequire = function(module)
  local ok, result = pcall(require, module)
  if ok then
    return result
  end
  return nil
end

--- Check if file exists
--- @param name string
_G.file_exists = function(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

--- Check if a command is executable
--- @param e string
--- @return boolean
_G.executable = function(e)
  return vim.fn.executable(e) > 0
end

--- Join path segments based on os type
--- @vararg string
--- @return string
_G.join_paths = function(...)
  local result = table.concat({ ... }, _G.path_sep)
  return result
end
