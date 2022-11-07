local api = vim.api
local fn = vim.fn
local log = require("conf.utils.log")

api.nvim_create_user_command(
  "Todo",
  [[noautocmd silent! grep! 'TODO\|FIXME\|BUG\|HACK' | copen]],
  {
    desc = "List todos in project",
  }
)

api.nvim_create_user_command(
  "MoveWrite",
  -- source: https://superuser.com/a/540519
  [[<line1>,<line2>write<bang> <args> | <line1>,<line2>delete _]],
  {
    desc = "Move visual selection to a file (overwrite)",
    bang = true,
    range = true,
    complete = "file",
    nargs = 1,
  }
)

api.nvim_create_user_command(
  "MoveAppend",
  -- source: https://superuser.com/a/540519
  [[<line1>,<line2>write<bang> >> <args> | <line1>,<line2>delete _]],
  {
    desc = "Move visual selection to a file (append)",
    bang = true,
    range = true,
    complete = "file",
    nargs = 1,
  }
)

api.nvim_create_user_command("Reload", function()
  -- Remove keymaps
  require("conf.utils.map").unmap_all()
  -- Unload config namespace
  for name, _ in pairs(package.loaded) do
    if name:match("^conf") then
      package.loaded[name] = nil
    end
  end
  -- Reload config
  dofile(vim.env.MYVIMRC)
  -- Run packer
  vim.cmd(":PackerInstall")
  vim.cmd(":PackerCompile")
  -- Start LSP
  if vim.fn.exists(":LspStart") ~= 0 then
    vim.defer_fn(function()
      vim.cmd("LspStart")
    end, 1000)
  end
  -- Manually run VimEnter autocmd to emulate a new run of Vim
  vim.cmd("doautocmd VimEnter")
  -- Notify
  log.info("Reloaded config!")
end, {
  desc = "Reload config",
})

api.nvim_create_user_command(
  "ToggleList",
  --- Toggle list (quickfix/loclist)
  --- @param opt table (1 arg) => prefix string: c or l
  function(opt)
    local prefix = opt.args
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local location_list = fn.getloclist(0, { filewinid = 0 })
      local is_loc_list = location_list.filewinid > 0
      if vim.bo[buf].filetype == "qf" or is_loc_list then
        fn.execute(prefix .. "close")
        return
      end
    end
    if prefix == "l" and vim.tbl_isempty(fn.getloclist(0)) then
      log.warn("Location List is Empty.", 2)
      return
    end

    local winnr = fn.winnr()
    fn.execute(prefix .. "open")
    if fn.winnr() ~= winnr then
      vim.cmd([[wincmd p]])
    end
  end,
  {
    desc = "Toggle quickfix or loclist",
    nargs = 1,
  }
)

api.nvim_create_user_command(
  "ToggleOption",
  --- Toggle an nvim option
  --- @param opt table (1 arg) => option string
  function(opt)
    local option = opt.args
    local info = vim.api.nvim_get_option_info(option)
    local scopes = { buf = "bo", win = "wo", global = "o" }
    local scope = scopes[info.scope]
    local options = vim[scope]
    options[option] = not options[option]
    if options[option] then
      log.warn("enabled vim." .. scope .. "." .. option, "Toggle")
    else
      log.warn("disabled vim." .. scope .. "." .. option, "Toggle")
    end
  end,
  {
    desc = "Toggle an nvim option",
    nargs = 1,
  }
)

api.nvim_create_user_command("BufDel", function(opt)
  -- Process args
  local args = opt.args
  local wipe = false
  if args and args == "1" then
    wipe = true
  end

  local killcmd = wipe and "bw" or "bd"
  local bufnr = 0
  if opt.bang then
    killcmd = killcmd .. "!"
  else
    killcmd = "confirm " .. killcmd
  end
  if bufnr == 0 or bufnr == nil then
    bufnr = vim.api.nvim_get_current_buf()
  end
  -- Get list of windows IDs with the buffer to close
  local windows = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_buf(win) == bufnr
  end, vim.api.nvim_list_wins())
  -- Get list of valid and listed buffers
  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())
  -- If there is only one buffer (which has to be the current one), vim will
  -- create a new buffer on :bd.
  -- For more than one buffer, pick the next buffer (wrapping around if necessary)
  if #buffers > 1 then
    for i, v in ipairs(buffers) do
      if v == bufnr then
        local next_buffer = buffers[i % #buffers + 1]
        for _, win in ipairs(windows) do
          vim.api.nvim_win_set_buf(win, next_buffer)
        end
        break
      end
    end
  end
  -- Check if buffer still exists, to ensure the target buffer wasn't killed
  -- due to options like bufhidden=wipe.
  if vim.api.nvim_buf_is_valid(bufnr) then
    local _, err = pcall(vim.cmd, string.format("%s %d", killcmd, bufnr))
    if not err == nil and not err == "" then
      require("conf.utils.log").error(err)
    end
  end
end, {
  desc = "Delete a buffer without affecting window layout",
  bang = true,
  nargs = 1,
})

api.nvim_create_user_command(
  "SetMinLogLevel",
  -- Set the minimum log level
  -- @param opt table (1 arg) => lvl integer
  function(opt)
    return log.set_min_log_level(tonumber(opt.args))
  end,
  {
    desc = "Set minimum log level: 1 (debug), 2 (info), 3 (warn), 4 (error)",
    nargs = 1,
  }
)

api.nvim_create_user_command(
  "GotoConflict",
  -- Set the minimum log level
  -- @param opt table (1 arg) => next/prev string
  function(opt)
    local action = opt.args == "prev" and "'bW'" or "'W'"
    vim.cmd(
      [[call search('^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)', ]] .. action .. [[)]]
    )
  end,
  {
    desc = "Goto git conflict marker (next/prev)",
    nargs = 1,
  }
)
