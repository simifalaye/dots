local lazy = require("utils.lazy")

--
-- Neovim global plugin for handling notes
--

if vim.g.loaded_user_plugin_notes then
  return
end
vim.g.loaded_user_plugin_notes = true

local default_notes_dir = vim.env.NOTES_DIR or vim.fs.joinpath(vim.env.HOME, "notes")

---@class LogNotesOpts
---@field disable? boolean
---@field dir? string
---@field script? string

---@type LogNotesOpts
local default_config = {
  disable = false,
  dir = default_notes_dir,
  script = "lognotes",
}

---@type LogNotesOpts | fun():LogNotesOpts
vim.g.notes = vim.g.notes

--- Get configuration
---@return LogNotesOpts
local function get_config()
  local opts = type(vim.g.notes) == "function" and vim.g.notes() or vim.g.notes or {}
  local config = vim.tbl_deep_extend("force", default_config, opts)
  return config
end

--
-- Functions
--

local M = {}

--- Execute notes script and return output
---@param args string[] Command arguments
---@param opts? table Options table
---@return string output
local function execute_notes(args, opts)
  opts = opts or {}

  local config = get_config()
  local env = {}
  env.IN_EDITOR = 1
  env.NOTES_DIR = config.dir

  local cmd = { config.script }
  vim.list_extend(cmd, args)

  local result = vim
    .system(cmd, {
      env = env,
      text = true,
    })
    :wait()

  if result.code ~= 0 then
    vim.notify(
      "Error running notes command: " .. (result.stderr or table.concat(args, " ")),
      vim.log.levels.ERROR
    )
    return ""
  end

  return result.stdout or ""
end

--- Get lines from command output
---@param output string Command output
---@return string[] lines
local function get_lines(output)
  local lines = {}
  for line in (output .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end
  return lines
end

--- Open file in buffer
---@param filepath string Path to file
local function open_file(filepath)
  vim.cmd("edit " .. vim.fn.fnameescape(filepath))
end

--- Run note command and open
---@param args string[] Command arguments
---@param opts? table Options table
local function execute_and_open(args, opts)
  local output = execute_notes(args, opts)
  local filepath = output:match("^%s*(.-)%s*$")
  if filepath and filepath ~= "" then
    open_file(filepath)
  end
end

--- LogNotes: today
function M.today()
  execute_and_open({ "today" })
end

--- LogNotes: yesterday
function M.yesterday()
  execute_and_open({ "yesterday" })
end

--- LogNotes: tomorrow
function M.tomorrow()
  execute_and_open({ "tomorrow" })
end

function M.capture()
  local notes_dir = get_config().dir
  local tmpfile = vim.trim(vim.fn.system({
    "mktemp",
    "--suffix=.md",
    "--tmpdir=" .. notes_dir,
  }))
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
    return
  end

  -- Open a new tab and set its local working directory.
  vim.cmd.tabnew()
  vim.cmd.lcd(vim.fn.fnameescape(get_config().dir))

  open_file(tmpfile)

  local bufnr = vim.api.nvim_get_current_buf()
  local tabpage = vim.api.nvim_get_current_tabpage()

  local captured = false
  local augroup =
    vim.api.nvim_create_augroup("LogNotesCapture" .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    buffer = bufnr,
    once = true,
    callback = function()
      if captured then
        return
      end
      captured = true

      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      -- Save changes if necessary.
      if vim.bo[bufnr].modified then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("silent write")
        end)
      end

      local ok, err = pcall(execute_notes, { "capture", tmpfile })

      vim.cmd.tabclose()

      if ok then
        vim.notify("Note captured", vim.log.levels.INFO)
      else
        vim.notify(err, vim.log.levels.ERROR)
      end
    end,
  })
  vim.api.nvim_create_autocmd({
    "BufDelete",
    "BufWipeout",
    "TabClosedPre",
    "VimLeavePre",
  }, {
    group = augroup,
    callback = function(ev)
      local function cleanup()
        pcall(vim.fn.delete, tmpfile)
        pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        pcall(vim.api.nvim_del_augroup, augroup)
      end

      if ev.event == "VimLeavePre" then
        cleanup()
        return
      end

      local t = vim.api.nvim_get_current_tabpage()
      if t ~= tabpage then
        return
      end
      vim.schedule(cleanup)
    end,
  })
end

--- LogNotes: tags
function M.list_tags()
  local output = execute_notes({ "list-tags" })
  local tags = get_lines(output)

  if #tags == 0 then
    vim.notify("No tags found", vim.log.levels.INFO)
    return
  end
  print(table.concat(tags, "\n"))
end

--- LogNotes: review
---@param args string[] Optional tag arguments
function M.review(args)
  args = args or {}

  if #args == 0 then
    local output = execute_notes({ "list-tags" })
    local tags = get_lines(output)

    if #tags == 0 then
      vim.notify("No tags found", vim.log.levels.INFO)
      return
    end

    vim.ui.select(tags, {
      prompt = "Select tags to review (Tab to multi-select): ",
    }, function(choice, _)
      if choice then
        M.review({ choice })
      end
    end)
  else
    local cmd = { "review" }
    vim.list_extend(cmd, args)

    local output = execute_notes(cmd)
    if output == "" or output:match("^No entries found") then
      vim.notify(
        "No entries found for tags: " .. table.concat(args, ", "),
        vim.log.levels.INFO
      )
      return
    end

    -- Open a new tab and set its local working directory.
    vim.cmd.tabnew()
    vim.cmd.lcd(vim.fn.fnameescape(get_config().dir))

    -- Set up buffer
    local bufnr = vim.api.nvim_get_current_buf()
    local tabpage = vim.api.nvim_get_current_tabpage()
    local lines = get_lines(output)
    local bufname = ("%s_%d"):format(args[1], vim.loop.hrtime())
    vim.cmd.file(bufname)
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].filetype = "markdown"
    vim.bo[bufnr].modified = true

    -- Write output and make it non-modifiable
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].readonly = true
    vim.bo[bufnr].modified = false

    local bufs = { [bufnr] = true }
    local augroup =
      vim.api.nvim_create_augroup("user.plugin.lognotes.review-" .. args[1], {})
    vim.api.nvim_create_autocmd("BufEnter", {
      group = augroup,
      callback = function(ev)
        local t = vim.api.nvim_get_current_tabpage()
        if t ~= tabpage then
          return
        end
        bufs[ev.buf] = true
      end,
    })
    vim.api.nvim_create_autocmd({ "TabClosedPre", "VimLeavePre" }, {
      group = augroup,
      callback = function(ev)
        local function cleanup()
          for b, _ in pairs(bufs) do
            pcall(vim.api.nvim_buf_delete, b, { force = true })
          end
          pcall(vim.api.nvim_del_augroup, augroup)
        end

        if ev.event == "VimLeavePre" then
          cleanup()
          return
        end

        local t = vim.api.nvim_get_current_tabpage()
        if t ~= tabpage then
          return
        end
        vim.schedule(cleanup)
      end,
    })
  end
end

--- LogNotes: rename-tag
function M.rename_tag()
  local output = execute_notes({ "list-tags" })
  local tags = get_lines(output)

  if #tags == 0 then
    vim.notify("No tags found", vim.log.levels.INFO)
    return
  end

  vim.ui.select(tags, {
    prompt = "Select tag to rename: ",
  }, function(old_tag, _)
    if old_tag then
      vim.ui.input({
        prompt = "New tag name: ",
        default = old_tag,
      }, function(new_tag)
        if new_tag and new_tag ~= "" then
          local cmd = { "rename-tag", old_tag, new_tag }
          local result = execute_notes(cmd)
          vim.notify(result, vim.log.levels.INFO)
        end
      end)
    end
  end)
end

--
-- Main
--

lazy.later(function()
  -- Commands
  vim.api.nvim_create_user_command("LogNotesToday", M.today, { desc = "Today" })
  vim.api.nvim_create_user_command(
    "LogNotesYesterday",
    M.yesterday,
    { desc = "Yesterday" }
  )
  vim.api.nvim_create_user_command("LogNotesTomorrow", M.tomorrow, { desc = "Tomorrow" })
  vim.api.nvim_create_user_command("LogNotesCapture", M.capture, { desc = "Capture" })
  vim.api.nvim_create_user_command("LogNotesTags", M.list_tags, { desc = "List tags" })
  vim.api.nvim_create_user_command("LogNotesReview", function(opts)
    M.review(opts.fargs)
  end, { desc = "Review", nargs = "*" })
  vim.api.nvim_create_user_command(
    "LogNotesRenameTag",
    M.rename_tag,
    { desc = "Rename tag" }
  )

  local prefix = "<leader>n"
  vim.keymap.set("n", prefix .. "t", M.today, { noremap = true, desc = "Today" })
  vim.keymap.set("n", prefix .. "y", M.yesterday, { noremap = true, desc = "Yesterday" })
  vim.keymap.set("n", prefix .. "m", M.tomorrow, { noremap = true, desc = "Tomorrow" })
  vim.keymap.set("n", prefix .. "c", M.capture, { noremap = true, desc = "Capture" })
  vim.keymap.set("n", prefix .. "l", M.list_tags, { noremap = true, desc = "List tags" })
  vim.keymap.set("n", prefix .. "r", M.review, { noremap = true, desc = "Review" })
  vim.keymap.set(
    "n",
    prefix .. "R",
    M.rename_tag,
    { noremap = true, desc = "Rename tag" }
  )
end)
