-- Load early so that globals can be set up
local asyncrpc = require("utils.asyncrpc")

local socket_prefix = "nvim."
local socket_name_match = "nvim%.(.+)"
local restart_message_file =
  vim.fs.joinpath(vim.fn.stdpath("state"), "mux_restart_message")

--
-- Config
--

local cfg = {
  -- directory where spawned sockets will be put
  session_dir = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath("run"), "..", "mux")),
  -- command used to spawn new nvim instances (table of args)
  spawn_cmd = { vim.v.progpath },
  -- automatically disconnect unmanaged servers when switching away
  detach_unmanaged = true,
}

--
-- Utils
--

local function notify_warn(...)
  vim.notify(string.format(...), vim.log.levels.WARN)
end

local function notify_error(...)
  vim.notify(string.format(...), vim.log.levels.ERROR)
end

local function notify_info(...)
  vim.notify(string.format(...), vim.log.levels.INFO)
end

local function mkdir(dir)
  if vim.fn.mkdir(dir, "p") ~= 1 then
    error("Failed to create directory " .. dir)
  end
end

--
-- MuxSession
--

---@class mux.Server
---@field ready boolean
---@field socket string
---@field pid integer
---@field start_time integer
---@field cwd string
---@field last_accessed integer
---@field last_updated integer
---@field pending_update boolean
---@field managed boolean

---@class mux.MuxSession
---@field name string
---@field original_cwd string
---@field server mux.Server
local MuxSession = {}
MuxSession.__index = MuxSession

--- Create new mux session
---@param name string
---@param dir string
---@param server mux.Server|nil
---@return mux.MuxSession
function MuxSession.new(name, dir, server)
  return setmetatable({ name = name, original_cwd = dir, server = server }, MuxSession)
end

--- Check if server is ready
---@return boolean
function MuxSession:ready()
  if not self.server or vim.uv.fs_stat(self.server.socket) == nil then
    return false
  end
  local err = asyncrpc.send(self.server.socket, [[]])
  if not err then
    self.server.ready = true
    return true
  else
    self.server.ready = false
    return false
  end
end

--- Spawn session
---@param on_ready fun(s: mux.MuxSession)?
function MuxSession:spawn(on_ready)
  if self.server and vim.uv.fs_stat(self.server.socket) ~= nil then
    return
  end

  local stat = vim.uv.fs_stat(self.original_cwd)
  assert(
    stat and stat.type == "directory",
    string.format("`%s` is not a directory", self.original_cwd)
  )

  -- Generate socket path and spawn neovim instance
  local socket = vim.fs.joinpath(cfg.session_dir, socket_prefix .. self.name)
  local cmd =
    vim.list_extend(vim.deepcopy(cfg.spawn_cmd), { "--headless", "--listen", socket })
  local chan = vim.fn.jobstart(cmd, {
    detach = true,
    cwd = self.original_cwd,
    stdin = "null",
    env = { MUX_SERVER_START = "1" },
  })
  if chan == 0 or chan == -1 then
    error(string.format("Failed to spawn nvim with command `%s`", table.concat(cmd, " ")))
  end

  self.server = {
    ready = false,
    socket = socket,
    pid = -1,
    start_time = 0,
    last_accessed = 0,
    last_updated = 0,
    cwd = vim.env.HOME,
    managed = true,
    pending_update = false,
  }

  local start = vim.uv.now()
  local timeout_ms = 5000

  -- Wait until server is ready, then fetch data and invoke callback.
  local function check()
    if self:ready() then
      self:fetch()

      if on_ready then
        on_ready(self)
      end
      return
    end

    if vim.uv.now() - start >= timeout_ms then
      notify_error("Timed out waiting for Neovim: %s", socket)
      return
    end

    vim.defer_fn(check, 50)
  end

  check()
end

--- Fetch data from server
function MuxSession:fetch()
  if not self.server or not self.server.ready then
    return
  end

  if self.server.socket == vim.v.servername then
    self.server.pid = vim.fn.getpid()
    self.server.start_time = vim.g.mux_start_time
    self.server.last_accessed = vim.g.mux_last_accessed
    self.cwd = vim.fn.getcwd()
    return
  end

  self.server.pending_update = true
  asyncrpc.request(
    self.server.socket,
    [[
      local pid = vim.fn.getpid()
      local start_time = 0
      local last_accessed = 0
      local cwd = vim.fn.getcwd()
      if vim.g.mux_start_time and type(vim.g.mux_start_time) == "number" then
        start_time = vim.g.mux_start_time
      end
      if vim.g.mux_last_accessed and type(vim.g.mux_last_accessed) == "number" then
        last_accessed = vim.g.mux_last_accessed
      end
      return { pid = pid, start_time = start_time, last_accessed = last_accessed, cwd = cwd }
    ]],
    function(resp)
      if not self.server then
        return
      end

      ---@cast resp asyncrpc.Response
      if not resp then
        return
      end
      if not resp.ok or not resp.value then
        -- TODO: debug log?
        -- notify_error("Failed to query server: %s, %s", self.name, resp.err or "no value")
        return
      end

      if resp.value.pid and type(resp.value.pid) == "number" then
        self.server.pid = resp.value.pid
      end
      if resp.value.start_time and type(resp.value.start_time) == "number" then
        self.server.start_time = resp.value.start_time
      end
      if resp.value.last_accessed and type(resp.value.last_accessed) == "number" then
        self.server.last_accessed = resp.value.last_accessed
      end
      if resp.value.cwd and type(resp.value.cwd) == "string" then
        self.server.cwd = resp.value.cwd
      end
      self.server.pending_update = false
      self.server.last_updated = vim.uv.hrtime()
    end
  )
end

--- Connect to session
---@param detach boolean
---@param cache table<string, mux.MuxSession>|nil
function MuxSession:connect(detach, cache)
  if self.server and self.server.socket == vim.v.servername then
    return
  end

  if detach and cache and cache[self.name] then
    cache[self.name] = nil
  end

  --- Connect to existing nvim server
  ---@param socket string
  local function switch_to(socket)
    if socket ~= vim.v.servername then
      vim.cmd({
        cmd = "connect",
        args = { socket },
        bang = detach == true,
      })
    end
  end

  if not self.server then
    self:spawn(function(s)
      switch_to(s.server.socket)
    end)
  else
    switch_to(self.server.socket)
  end
end

--- Detach session
function MuxSession:detach()
  if not self.server then
    return
  end

  local unsaved
  if self.server.socket == vim.v.servername then
    unsaved = vim.tbl_filter(function(b)
      return vim.bo[b.bufnr].buftype == ""
    end, vim.fn.getbufinfo({ bufmodified = 1 }))
  else
    local res, err = asyncrpc.requestwait(
      self.server.socket,
      [[
        return vim.tbl_filter(
          function(b) return vim.bo[b.bufnr].buftype == "" end,
          vim.fn.getbufinfo({ bufmodified = 1 })
        )
      ]],
      800
    )
    if err then
      notify_warn(
        "Could not query session '%s' for unsaved buffers: %s",
        self.name,
        tostring(err)
      )
      return
    end
    unsaved = res
  end

  ---@cast unsaved vim.fn.getbufinfo.ret.item[]
  if unsaved and #unsaved > 0 then
    local names = vim.tbl_map(function(b)
      return "`" .. vim.fn.fnamemodify(b.name, ":~:.") .. "`"
    end, unsaved)
    local check = table.concat(names, ", ")
    notify_warn(
      "Can't close session '%s' due to unsaved changes. Check %s",
      self.name,
      check
    )
  else
    asyncrpc.send(self.server.socket, "vim.defer_fn(vim.cmd.qall, 100)")
  end
end

--
-- Helpers
--

---@type table<string, mux.MuxSession>
local session_cache = {}

--- Update session cache with new sessions and cleanup old sessions
local function sync_session_cache()
  ---@type string[]
  local sockets = vim.tbl_filter(function(s)
    return vim.startswith(vim.fs.basename(s), socket_prefix)
  end, vim.fn.serverlist({ peer = true }))

  ---@type table<string, boolean>
  local active_sockets = {}

  for _, socket in ipairs(sockets) do
    local stat = vim.uv.fs_stat(socket)
    if stat and stat.type == "socket" then
      active_sockets[socket] = true

      local dir = vim.fs.normalize(vim.fs.dirname(socket))
      local name = socket:match("nvim%.(.+)")

      if not session_cache[name] then
        session_cache[name] = MuxSession.new(name, dir, {
          ready = false,
          socket = socket,
          pid = -1,
          start_time = 0,
          last_accessed = 0,
          last_updated = 0,
          cwd = vim.env.HOME,
          managed = dir == cfg.session_dir,
          pending_update = false,
        })
        session_cache[name]:ready()
      end
    end
  end

  -- Remove sessions whose sockets are no longer active.
  for name, session in pairs(session_cache) do
    if session.server then
      if not active_sockets[session.server.socket] then
        asyncrpc.close_channel(session_cache[name].server.socket)
        session_cache[name] = nil
      end
    end
  end
end

--- Fetch latest server data for each session
local function sync_session_servers()
  for _, session in pairs(session_cache) do
    if session.server then
      session:fetch()
    end
  end
end

--- Return sorted sessions
---@param exclude_current boolean|nil
---@return mux.MuxSession[]
local function list_sessions(exclude_current)
  sync_session_cache()

  local sorted_sessions = vim.tbl_values(session_cache)
  table.sort(sorted_sessions, function(a, b)
    if vim.fs.normalize(a.server.socket) == vim.v.servername then
      return true
    end
    if vim.fs.normalize(b.server.socket) == vim.v.servername then
      return false
    end
    return a.server.last_accessed > b.server.last_accessed
  end)
  if exclude_current == true then
    return vim.tbl_filter(function(s)
      return s.server.socket ~= vim.v.servername
    end, sorted_sessions)
  end
  return sorted_sessions
end

--- Get sessions by count
---@param count integer
---@return mux.MuxSession|nil
local function get_session_by_count(count)
  local sessions = list_sessions(true)
  local out = sessions[count]
  if not out then
    return nil
  end
  return out
end

--
-- API
--

local M = {}

local function should_detach()
  if not cfg.detach_unmanaged then
    return false
  end

  local current = M.current()
  if current then
    return not current.server.managed
  end
  return false
end

--- Return current mux session
---@return mux.MuxSession|nil
function M.current()
  local socket = vim.v.servername
  local name = socket:match(socket_name_match)
  if not name then
    return nil
  end
  return session_cache[name] or nil
end

--- Create a new mux session in a specified directory
---@param dir string?
---@param name string?
function M.add(dir, name)
  if not dir or dir == "" then
    vim.ui.input({
      prompt = "dir: ",
      default = vim.fn.getcwd(),
      completion = "dir",
    }, function(value)
      if value and value ~= "" then
        M.add(value, name)
      end
    end)
    return
  end
  dir = vim.fs.normalize(dir)

  if not name or name == "" then
    vim.ui.input({
      prompt = "Name (optional): ",
      default = vim.fs.basename(dir),
    }, function(value)
      if value and value ~= "" then
        M.add(dir, value)
      end
    end)
    return
  end

  if not vim.fn.isdirectory(dir) then
    notify_error("Directory does not exist: %s", dir)
    return
  end

  if session_cache[name] then
    notify_error("Session '%s' already exists", name)
    return
  end

  session_cache[name] = MuxSession.new(name, dir)
  session_cache[name]:connect(should_detach(), session_cache)
end

--- Switch to a mux session
---@param name string?
function M.switch(name)
  if not name or name == "" then
    local sessions = list_sessions(true)
    if #sessions == 0 then
      notify_info("No other sessions available")
      return
    end
    vim.ui.select(sessions, {
      prompt = "Select session: ",
      format_item = function(item)
        ---@cast item mux.MuxSession
        return item.name
      end,
    }, function(value)
      if value and value ~= "" then
        M.switch(value.name)
      end
    end)
    return
  end

  -- Don't switch to current project
  local current = M.current()
  if current and name == current.name then
    return
  end

  local session = session_cache[name]
  if not session then
    notify_error("No session exists exists named: %s", name)
    return
  end

  -- Switch
  local ok, err = pcall(MuxSession.connect, session, should_detach(), session_cache)
  if not ok then
    notify_error(err)
  end
end

--- Switch to last session
function M.switch_last()
  local last_session = get_session_by_count(1)
  if not last_session then
    notify_info("No last session")
    return
  end

  -- Switch
  local ok, err = pcall(MuxSession.connect, last_session, should_detach(), session_cache)
  if not ok then
    notify_error(err)
    return
  end
end

--- Delete a session
---@param name string? Session name
function M.delete(name)
  if not name or name == "" then
    local sessions = list_sessions()
    if #sessions == 0 then
      notify_info("No sessions available")
      return
    end
    vim.ui.select(sessions, {
      prompt = "Delete session: ",
      format_item = function(item)
        ---@cast item mux.MuxSession
        if item.server and item.server.socket == vim.v.servername then
          return item.name .. " (current)"
        end
        return item.name
      end,
    }, function(value)
      if value and value ~= "" then
        M.delete(value.name)
      end
    end)
    return
  end

  local session = session_cache[name]
  if not session then
    notify_error("Session does not exist: ", session.name)
    return false
  end

  local choice =
    vim.fn.confirm(('Delete session "%s"?'):format(session.name), "&Yes\n&No")
  if choice == 1 then
    if vim.v.servername == session.name then
      local last_session = get_session_by_count(1)
      if last_session then
        local ok, err = pcall(MuxSession.connect, last_session, true, session_cache)
        if not ok then
          notify_error(err)
          return
        end
      else
        vim.cmd.qall()
      end
    else
      session:detach()
      session_cache[session.name] = nil
      notify_info("Deleted session: %s", name)
    end
  end
end

--- Restart all sessions
function M.restart()
  local sessions = list_sessions(true)
  local sent = 0
  local success = 0
  local failed = 0
  for _, session in ipairs(sessions) do
    if session.server then
      sent = sent + 1
      local err =
        asyncrpc.send(session.server.socket, [[vim.g.mux_restart_scheduled = true]])
      if err then
        failed = failed + 1
      else
        success = success + 1
      end
    end
  end

  vim.fn.writefile({
    ("Scheduled restart for %d/%d server(s); restarted current instance"):format(
      success,
      sent
    ),
  }, restart_message_file)

  vim.defer_fn(function()
    vim.cmd.restart()
  end, 100)
end

--- Quit all sessions
function M.quit()
  local sessions = list_sessions(true)
  for _, session in ipairs(sessions) do
    if session.server then
      asyncrpc.send(session.server.socket, [[vim.cmd.qall()]])
    end
  end

  vim.defer_fn(function()
    vim.cmd.qall()
  end, 100)
end

_G.Mux = M

--
-- Main
--

local lazy = require("utils.lazy")
lazy.now(function()
  -- Handle restart message
  if vim.fn.filereadable(restart_message_file) == 1 then
    local lines = vim.fn.readfile(restart_message_file)
    vim.fn.delete(restart_message_file)
    vim.schedule(function()
      notify_info(table.concat(lines, "\n"))
    end)
  end

  -- On first startup, open directory buffer
  if vim.env.MUX_SERVER_START and vim.env.MUX_SERVER_START == "1" then
    vim.cmd.edit(".")
    -- Clear env for any restarts
    vim.env.MUX_SERVER_START = nil
  end

  -- Store current server data
  vim.g.mux_start_time = vim.g.mux_start_time or vim.uv.hrtime()
  vim.g.mux_last_accessed = vim.g.mux_last_accessed or 0
  vim.g.mux_restart_scheduled = vim.g.mux_restart_scheduled or false

  -- ensure session dir exists
  mkdir(cfg.session_dir)

  -- load sessions immediately
  sync_session_cache()
  sync_session_servers()

  -- Autocommands
  local augroup = vim.api.nvim_create_augroup("user_plugin_mux", { clear = true })
  vim.api.nvim_create_autocmd("UIEnter", {
    desc = "Update session data on UIEnter",
    group = augroup,
    callback = function()
      if vim.g.mux_restart_scheduled then
        vim.g.mux_restart_scheduled = false
        vim.schedule(function()
          vim.fn.writefile({ "Restarted current instance" }, restart_message_file)
          vim.defer_fn(function()
            vim.cmd.restart()
          end, 100)
        end)
      else
        vim.g.mux_last_accessed = vim.uv.hrtime()
        sync_session_cache()
        sync_session_servers()
      end
    end,
  })

  -- Commands
  vim.api.nvim_create_user_command("MuxAdd", function(opts)
    local args = opts.fargs
    M.add(args[1], args[2])
  end, {
    nargs = "*",
    complete = "dir",
    desc = "Add a directory as a project",
  })
  vim.api.nvim_create_user_command("MuxSwitch", function(opts)
    M.switch(opts.args)
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_map(function(item)
        return item.name
      end, list_sessions(true))
    end,
    desc = "Switch to a mux session",
  })
  vim.api.nvim_create_user_command("MuxSwitchLast", function()
    M.switch_last()
  end, {
    desc = "Switch to last mux session",
  })
  vim.api.nvim_create_user_command("MuxDelete", function(opts)
    M.delete(opts.args)
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_map(function(item)
        return item.name
      end, list_sessions())
    end,
    desc = "Delete a project",
  })
  vim.api.nvim_create_user_command("MuxCurrent", function()
    local current = M.current()
    notify_info(current and current.name or "No session loaded")
  end, {
    desc = "Show the current session",
  })
  vim.api.nvim_create_user_command("MuxRestart", function()
    M.restart()
  end, {
    desc = "Restart all sessions",
  })
  vim.api.nvim_create_user_command("MuxQuitAll", function()
    M.quit()
  end, {
    desc = "Quit all sessions",
  })

  -- Keymaps
  vim.keymap.set("n", "<C-Space><Space>", "<cmd>MuxSwitchLast<CR>", { desc = "Last" })
  vim.keymap.set("n", "<C-Space>a", "<cmd>MuxAdd<CR>", { desc = "Add" })
  vim.keymap.set("n", "<C-Space>c", "<cmd>MuxCurrent<CR>", { desc = "Current" })
  vim.keymap.set("n", "<C-Space>d", "<cmd>MuxDelete<CR>", { desc = "Delete" })
  vim.keymap.set("n", "<C-Space>q", "<cmd>MuxQuitAll<CR>", { desc = "Quit" })
  vim.keymap.set("n", "<C-Space>r", "<cmd>MuxRestart<CR>", { desc = "Restart" })
  vim.keymap.set("n", "<C-Space>s", "<cmd>MuxSwitch<CR>", { desc = "Switch" })
end)
