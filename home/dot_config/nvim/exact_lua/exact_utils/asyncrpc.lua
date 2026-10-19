--
-- AsyncRPC
--
-- Protocol:
-- - Caller calls asyncrpc.request(socket, lua_code, callback?)
--   - If callback provided: an ident is allocated and recorded in pending.
--   - The caller uses vim.fn.sockconnect + vim.rpcnotify("nvim_exec_lua", ...) to run
--     _G.server_handle_request(ident, lua_code, origin_socket) on the target server.
-- - On the server, _G.server_handle_request executes the lua_code (safely with pcall),
--   packs the results and connects back to origin_socket with a new rpcnotify calling
--   nvim_exec_lua to invoke _G.server_handle_response(ident, response).
-- - The caller's _G.server_handle_response receives the response and cancels the timer
--   and dispatches the callback from the pending table.
--

---@alias asyncrpc.SendErr "connect_failed"
---@alias asyncrpc.RequestErr "timer_failed" | "connect_failed"
---@alias asyncrpc.RequestWaitErr asyncrpc.RequestErr | "timeout" | "no_response" | "remote_error"

---@class asyncrpc.Response
---@field ok boolean
---@field value any|nil
---@field err string|nil

---@alias asyncrpc.RequestCb fun(asyncrpc.Response)

---@class asyncrpc.RequestObj
---@field cb asyncrpc.RequestCb
---@field timer uv.uv_timer_t

--
-- Locals
--

local default_timeout = 1000
local next_ident = 0

---@type table<integer, asyncrpc.RequestObj>
local pending = {}

local function alloc_ident()
  next_ident = next_ident + 1
  return tostring(next_ident)
end

-- Helper to safely stop+close a uv timer (ignore errors)
local function stop_and_close_timer(t)
  if not t then
    return
  end
  pcall(function()
    t:stop()
  end)
  pcall(function()
    t:close()
  end)
end

--
-- Globals
--

-- Define globals that server & client use in the protocol.
-- These are defined here so that when this file is loaded on both endpoints the handlers exist.

--- Executes lua code on server and sends back a response (only one value is allowed)
---@param ident string the identifier for the request
---@param lua_code string the lua chunk to execute
---@param origin_socket string the socket to reply to
_G.server_handle_request = function(ident, lua_code, origin_socket)
  ---@type asyncrpc.Response
  local resp = { ok = false, value = nil, err = nil }
  local ok, pack_or_err = pcall(function()
    local f, load_err = load(lua_code)
    if not f then
      error(load_err or "failed to load chunk")
    end
    local success, value = pcall(f)
    if not success then
      error(value)
    end
    return value
  end)

  if ok then
    resp.ok = true
    resp.value = pack_or_err
  else
    resp.ok = false
    resp.err = tostring(pack_or_err)
  end

  if origin_socket and origin_socket ~= "" then
    local chan = vim.fn.sockconnect("pipe", origin_socket, { rpc = true })
    if chan == 0 or chan == -1 then
      return
    end
    vim.rpcnotify(
      chan,
      "nvim_exec_lua",
      [[
        if _G and type(_G.server_handle_response) == "function" then
          _G.server_handle_response(...)
        end
      ]],
      { ident, resp }
    )
    vim.defer_fn(function()
      vim.fn.chanclose(chan)
    end, 100)
  end
end

--- Handle a response from a request
---@param ident string the identifier for the request
---@param resp asyncrpc.Response response from the server
_G.server_handle_response = function(ident, resp)
  local entry = pending[ident]
  if not entry then
    -- nothing pending, drop
    return
  end
  pending[ident] = nil
  -- stop and close timer
  if entry.timer then
    stop_and_close_timer(entry.timer)
  end
  local cb = entry.cb
  if cb then
    -- schedule callback on main loop
    vim.schedule(function()
      pcall(cb, resp)
    end)
  end
end

--
-- API
--

local M = {}

--- Send fire and forget notification to remote server
---@param socket string path to server pipe
---@param lua_code string lua chunk to execute
---@return asyncrpc.SendErr|nil
function M.send(socket, lua_code)
  -- connect and notify
  local chan = vim.fn.sockconnect("pipe", socket, { rpc = true })
  if chan == 0 or chan == -1 then
    return "connect_failed"
  end
  vim.rpcnotify(chan, "nvim_exec_lua", lua_code, {})
  vim.defer_fn(function()
    vim.fn.chanclose(chan)
  end, 100)
  return nil
end

--- Make request to remote server and handle response
---@param socket string path to pipe
---@param lua_code string lua chunk to execute on remote server (should be safe)
---@param callback asyncrpc.RequestCb
---@param timeout_ms integer|nil ms
---@return string|nil, asyncrpc.RequestErr|nil
function M.request(socket, lua_code, callback, timeout_ms)
  timeout_ms = timeout_ms or default_timeout

  local origin = vim.v.servername
  local ident
  ident = alloc_ident()
  -- create timer now, but do not start it yet (so we can store it with the pending entry)
  local timer = vim.uv.new_timer()
  if not timer then
    -- call back asynchronously to keep behavior consistent
    vim.schedule(function()
      pcall(callback, { ok = false, err = "internal timer failure" })
    end)
    return nil, "timer_failed"
  end

  pending[ident] = {
    cb = callback,
    timer = timer,
  }

  -- Timer callback: runs on timeout, cleans up pending and calls the callback with a timeout error.
  timer:start(
    timeout_ms,
    0,
    vim.schedule_wrap(function()
      local entry = pending[ident]
      if not entry then
        -- already handled
        stop_and_close_timer(timer)
        return
      end
      pending[ident] = nil
      -- call callback with timeout error on main loop
      pcall(vim.schedule, function()
        pcall(entry.cb, { ok = false, err = "timeout" })
      end)
      stop_and_close_timer(timer)
    end)
  )

  -- connect and notify
  local chan = vim.fn.sockconnect("pipe", socket, { rpc = true })
  if chan == 0 or chan == -1 then
    -- immediate failure to connect
    local entry = pending[ident]
    pending[ident] = nil
    -- stop and close timer
    if entry and entry.timer then
      stop_and_close_timer(entry.timer)
    end
    -- call back asynchronously to keep behavior consistent
    vim.schedule(function()
      pcall(
        callback,
        { ok = false, err = "failed to connect to socket: " .. tostring(socket) }
      )
    end)
    return nil, "connect_failed"
  end

  -- run _G.server_handle_request(...) on the remote instance.
  vim.rpcnotify(
    chan,
    "nvim_exec_lua",
    [[
        -- args: ident, lua_code, origin_socket
        if _G and type(_G.server_handle_request) == "function" then
          _G.server_handle_request(...)
        else
          -- fallback: execute chunk but no response
          local ident, lua_code, origin = ...
          local ok, f = pcall(load, lua_code)
          if ok and f then
            pcall(f)
          end
        end
      ]],
    { ident, lua_code, origin }
  )
  vim.defer_fn(function()
    vim.fn.chanclose(chan)
  end, 100)

  return ident, nil
end

--- Convenience wrapper that waits up to timeout_ms for a reply
---@param socket string path to server pipe
---@param lua_code string lua chunk to execute
---@param timeout_ms integer ms
---@return any[]|nil, asyncrpc.RequestWaitErr|nil
function M.requestwait(socket, lua_code, timeout_ms)
  timeout_ms = timeout_ms or default_timeout
  ---@type asyncrpc.Response
  local resp
  local done = false

  M.request(socket, lua_code, function(r)
    resp = r
    done = true
  end, timeout_ms)

  -- wait until done or timeout_ms
  local waited = vim.wait(timeout_ms, function()
    return done
  end, 10)
  if not waited then
    -- request timed out
    return nil, "timeout"
  end

  if not resp then
    return nil, "no_response"
  end

  if not resp.ok then
    return nil, resp.err or "remote_error"
  end

  return resp.value, nil
end

--- Cancel pending request
---@param ident string
function M.cancel(ident)
  if not ident then
    return
  end
  local entry = pending[ident]
  if entry then
    pending[ident] = nil
    if entry.timer then
      stop_and_close_timer(entry.timer)
    end
  end
end

return M
