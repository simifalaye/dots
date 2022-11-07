local fn = vim.fn
local uv = vim.loop

local M = {}

-- Path separator based on os
M.path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"

--- Check if file exists
--- @param name string
M.file_exists = function(name)
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
M.executable = function(e)
  return fn.executable(e) > 0
end

--- Join path segments based on os type
--- @vararg string
--- @return string
M.join_paths = function(...)
  local result = table.concat({ ... }, M.path_sep)
  return result
end

--- Get source path of dotfiles
--- @return string
M.dotpath = function()
  local path = M.join_paths(os.getenv("HOME"), ".local", "chezmoi")
  if M.executable("chezmoi") then
    path = fn.system("chezmoi source-path")
  end
  return path:gsub("[\n\r]", "")
end

-- Packer install path
M.packer_dir =
  M.join_paths(fn.stdpath("data"), "site", "pack", "packer", "start")

return M
