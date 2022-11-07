---@diagnostic disable: return-type-mismatch
-- Logging utility for config
-- NOTE: You can start nvim with a specific log level by passing it as an
-- environment variable to the command (ex. 'NVIM_MIN_LOG_LEVEL=1 nvim')
-- Modified from https://github.com/svermeulen/vimpeccable

--- The diagnostic log levels
local LogLevels = {
  debug = 1,
  info = 2,
  warn = 3,
  error = 4,
  all = {
    1,
    2,
    3,
    4,
  },
  strings = {
    "debug",
    "info",
    "warn",
    "error",
  },
  highlights = {
    "DiagnosticHint",
    "DiagnosticInfo",
    "DiagnosticWarn",
    "DiagnosticError",
  },
}

--- Log printer type
local PrintLogStream
do
  local _class_0
  local _base_0 = {
    log = function(self, message, level)
      if level >= self.min_log_level then
        local name = string.format("[%s]: ", tostring(LogLevels.strings[level]))
        local hl = LogLevels.highlights[level]
        vim.api.nvim_echo({ { name, hl }, { message } }, true, {})
      end
    end,
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      local lvl = tonumber(vim.env.NVIM_MIN_LOG_LEVEL)
      self.min_log_level = LogLevels.all[lvl] or LogLevels.info
      vim.env.NVIM_MIN_LOG_LEVEL = self.min_log_level
    end,
    __base = _base_0,
    __name = "PrintLogStream",
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end,
  })
  _base_0.__class = _class_0
  PrintLogStream = _class_0
end
local print_log_stream = PrintLogStream()

--- Logger module
local log
do
  local _class_0
  local _base_0 = {
    fmt = string.format,
    levels = LogLevels,
    streams = {
      print_log_stream,
    },
    print_log_stream = print_log_stream,
    --- Log a message to user
    ---@param message string
    ---@param level integer
    log = function(message, level)
      if message == nil then
        message = "nil"
      elseif type(message) ~= "string" then
        message = tostring(message)
      end
      local _list_0 = log.streams
      for _index_0 = 1, #_list_0 do
        local stream = _list_0[_index_0]
        stream:log(message, level)
      end
    end,
    --- Log a debug message to user
    ---@param message string
    ---@return any
    debug = function(message)
      return log.log(message, LogLevels.debug)
    end,
    --- Log an info message to user
    ---@param message string
    ---@return any
    info = function(message)
      return log.log(message, LogLevels.info)
    end,
    --- Log a warn message to user
    ---@param message string
    ---@return any
    warn = function(message)
      return log.log(message, LogLevels.warn)
    end,
    --- Log an error message to user
    ---@param message string
    ---@return any
    error = function(message)
      return log.log(message, LogLevels.error)
    end,
    --- Convert a log level string to the integer value
    ---@param log_level_str string
    ---@return integer
    string_to_log_level = function(log_level_str)
      for i = 1, #LogLevels.strings do
        if log_level_str == LogLevels.strings[i] then
          return i
        end
      end
      return error("Invalid log level '" .. tostring(log_level_str) .. "'")
    end,
    --- Set the minimum log level
    ---@param log_level integer
    ---@return boolean true if successful
    set_min_log_level = function(log_level)
      if LogLevels.all[log_level] then
        vim.env.NVIM_MIN_LOG_LEVEL = log_level
        print_log_stream.min_log_level = log_level
        return true
      end
      return error("Bad log level provided: " .. tostring(log_level))
    end,
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "log",
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end,
  })
  _base_0.__class = _class_0
  log = _class_0
  return _class_0
end
