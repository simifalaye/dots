local git = require("utils.git")
local hl = require("utils.hl")
local icons = require("static.icons")
local augroup = vim.api.nvim_create_augroup("user.statusline", {})

--
-- Helpers
--

local function is_empty(s)
  return s == nil or s == ""
end

local function option(buf, name)
  return vim.api.nvim_get_option_value(name, { buf = buf })
end

local set_hl_groups = function()
  local basefg = hl.normalize_fg_or_bg("fg", "StatusLine", "#ffffff")
  local basebg = hl.normalize_fg_or_bg("bg", "StatusLine", "#000000")
  for group, opts in pairs({
    ModeNormal = { fg = basebg, bg = basefg },
    ModePending = { fg = basebg, bg = hl.normalize_fg_or_bg("fg", "Comment", "#636363") },
    ModeVisual = { fg = basebg, bg = hl.normalize_fg_or_bg("fg", "Number", "#ffae45") },
    ModeInsert = { fg = basebg, bg = hl.normalize_fg_or_bg("fg", "String", "#4ca13f") },
    ModeCommand = { fg = basebg, bg = hl.normalize_fg_or_bg("fg", "Keyword", "#53e0ed") },
    ModeReplace = { fg = basebg, bg = hl.normalize_fg_or_bg("fg", "Error", "#ed3434") },
    Bold = { fg = basefg, bg = basebg, bold = true },
    Dim = { fg = hl.normalize_fg_or_bg("fg", "LineNr", "#ebebeb"), bg = basebg },
  }) do
    group = "StatusLine" .. group
    hl.set(0, group, opts)
    opts.fg, opts.bg = opts.bg, opts.fg
    hl.set(0, group .. "Inverted", opts)
  end
end

--
-- Components
--

-- Note: termcodes \19 and \22 are ^S and ^V
---- stylua: ignore
local mode_settings = {
  ["n"] = { name = "NORMAL", hl = "Normal" },
  ["no"] = { name = "OP-PENDING", hl = "Pending" },
  ["nov"] = { name = "OP-PENDING", hl = "Pending" },
  ["noV"] = { name = "OP-PENDING", hl = "Pending" },
  ["no\22"] = { name = "OP-PENDING", hl = "Pending" },

  ["niI"] = { name = "NORMAL", hl = "Normal" },
  ["niR"] = { name = "NORMAL", hl = "Normal" },
  ["niV"] = { name = "NORMAL", hl = "Normal" },
  ["nt"] = { name = "NORMAL", hl = "Normal" },
  ["ntT"] = { name = "NORMAL", hl = "Normal" },

  ["v"] = { name = "VISUAL", hl = "Visual" },
  ["vs"] = { name = "VISUAL", hl = "Visual" },
  ["V"] = { name = "V-LINE", hl = "Visual" },
  ["Vs"] = { name = "V-LINE", hl = "Visual" },
  ["\22"] = { name = "V-BLOCK", hl = "Visual" },

  ["\22s"] = { name = "V-BLOCK", hl = "Visual" },
  ["s"] = { name = "SELECT", hl = "Insert" },
  ["S"] = { name = "S-LINE", hl = "Normal" },
  ["\19"] = { name = "S-BLOCK", hl = "Normal" },
  ["i"] = { name = "INSERT", hl = "Insert" },
  ["ic"] = { name = "INSERT", hl = "Insert" },
  ["ix"] = { name = "INSERT", hl = "Insert" },
  ["R"] = { name = "REPLACE", hl = "Replace" },
  ["Rc"] = { name = "REPLACE", hl = "Replace" },
  ["Rx"] = { name = "REPLACE", hl = "Replace" },
  ["Rv"] = { name = "V-REPLACE", hl = "Replace" },
  ["Rvc"] = { name = "V-REPLACE", hl = "Replace" },
  ["Rvx"] = { name = "V-REPLACE", hl = "Replace" },
  ["c"] = { name = "COMMAND", hl = "Command" },
  ["cv"] = { name = "EX", hl = "Command" },
  ["ce"] = { name = "EX", hl = "Command" },
  ["r"] = { name = "REPLACE", hl = "Normal" },
  ["rm"] = { name = "MORE", hl = "Normal" },
  ["r?"] = { name = "CONFIRM", hl = "Normal" },
  ["!"] = { name = "SHELL", hl = "Normal" },
  ["t"] = { name = "TERMINAL", hl = "Command" },
}

local function get_mode()
  return mode_settings[vim.fn.mode()] or { name = "??", hl = "Normal" }
end

local function comp_mode()
  local mode = get_mode()
  return hl.make_hl_str(" " .. mode.name .. " ", "StatusLineMode" .. mode.hl)
end

local function comp_search(buf)
  local lines = vim.api.nvim_buf_line_count(buf)
  if lines > 50000 then
    return ""
  end

  local query = vim.fn.getreg("/")
  if query == "" then
    return ""
  end

  if query:find("@") then
    return ""
  end

  local search_count = vim.fn.searchcount({ recompute = 1, maxcount = -1 })
  local active = false
  if vim.v.hlsearch and vim.v.hlsearch == 1 and search_count.total > 0 then
    active = true
  end
  if not active then
    return ""
  end

  query = query:gsub([[^\V]], "")
  query = query:gsub([[\<]], ""):gsub([[\>]], "")

  local mode = get_mode()

  return hl.make_hl_str(
    (" %s/%s "):format(search_count.current, search_count.total),
    "StatusLineMode" .. mode.hl
  )
end

local function comp_macro()
  if vim.fn.reg_recording() == "" then
    return ""
  end

  local mode = get_mode()

  return hl.make_hl_str(
    (" %s%s "):format("  ", vim.fn.reg_recording()),
    "StatusLineMode" .. mode.hl
  )
end

local function comp_git_info(buf)
  local work_tree, git_dir = git.resolve_context(buf, {})
  if not work_tree or not git_dir then
    return ""
  end

  local use_cur_repo_args = { "--git-dir", git_dir, "--work-tree", work_tree }
  -- Use `--abbrev-ref` for branch name. In detached mode, this gives 'HEAD'
  -- as the abbrev ref which is useless, then fallback to actual commit id
  -- with `--short`
  local branch = git.execute(
    0,
    vim.list_extend(
      vim.deepcopy(use_cur_repo_args),
      { "rev-parse", "--abbrev-ref", "HEAD" }
    )
  )
  if branch == "HEAD" then
    branch = git.execute(
      buf,
      vim.list_extend(vim.deepcopy(use_cur_repo_args), { "rev-parse", "--short", "HEAD" })
    )
  end

  if not branch then
    return ""
  end

  local ahead, behind = 0, 0
  local ahead_behind = git.execute(
    buf,
    vim.list_extend(
      vim.deepcopy(use_cur_repo_args),
      { "rev-list", "--left-right", "--count", "HEAD...@{u}" }
    )
  )
  if ahead_behind then
    local a, b = ahead_behind:match("(%d+)%s+(%d+)")
    ahead, behind = tonumber(a) or 0, tonumber(b) or 0
  end

  return ("%s%s%s"):format(
    icons.Font.Ft.Git,
    branch,
    (ahead > 0 or behind > 0) and "↻" or " "
  )
end

local function comp_diag(buf)
  local counts = vim.diagnostic.count(buf)
  local sev = vim.diagnostic.severity
  local parts = {}

  for _, item in ipairs({
    { sev.ERROR, icons.Font.Diag.Error },
    { sev.WARN, icons.Font.Diag.Warn },
  }) do
    local count = counts[item[1]] or 0
    parts[#parts + 1] = item[2] .. " " .. count
  end

  return table.concat(parts, " ")
end

local function comp_server()
  local servername = vim.v.servername
  if is_empty(servername) then
    return ""
  end

  if _G.Mux and _G.Mux.current then
    local current = _G.Mux.current()
    if current then
      servername = current.name
    end
  end

  return (" %s"):format(servername)
end

local function comp_cursor(win)
  local cursor = vim.api.nvim_win_get_cursor(win)
  local line = cursor[1]
  local col = cursor[2] + 1
  return ("Ln %d, Col %d"):format(line, col)
end

local function comp_spaces(buf)
  local shiftwidth = option(buf, "shiftwidth")
  if shiftwidth == 0 then
    shiftwidth = option(buf, "tabstop")
  end
  return ("Spaces: %d"):format(shiftwidth)
end

local function comp_fileenconding(buf)
  return option(buf, "fileencoding") ~= "" and option(buf, "fileencoding"):upper()
    or option(nil, "encoding"):upper()
end

local function comp_fileformat(buf)
  return option(buf, "fileformat"):upper()
end

local function comp_filetype(buf)
  local ft = option(buf, "filetype")
  if ft == "" then
    return "Plain Text"
  end

  local icon = "{}"
  local icon_hl = "StatusLine"
  local ok_mini_icons, mini_icons = pcall(require, "mini.icons")
  if ok_mini_icons then
    icon, icon_hl = mini_icons.get("filetype", ft)
  end

  return hl.make_hl_str(("%s"):format(icon), icon_hl) .. (" %s"):format(string.upper(ft))
end

--
-- Init
--

local initialized = false

local function init()
  if initialized then
    return
  end

  vim.opt.shortmess = vim.opt.shortmess + "S" -- don't show search count [n/m]
  vim.opt.shortmess = vim.opt.shortmess + "q" -- don't show "recording @<key>"

  initialized = true
end

-- Compile and apply our custom highlights
set_hl_groups()

-- Re-compile statusline colours when the colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Re-apply statusline highlights on colorscheme change",
  group = augroup,
  callback = set_hl_groups,
})

return {
  render = function()
    init()

    local active_win = vim.api.nvim_get_current_win()
    local status_win = tonumber(vim.g.statusline_winid) or active_win
    local status_active = active_win == status_win

    local mb_ok, mb = pcall(require, "minibuffer")
    if mb_ok and mb.is_active and mb.get_active_window and mb.is_active() then
      status_active = status_win == mb.get_active_window()
    end

    local buf = vim.api.nvim_win_get_buf(status_win)

    local right = {
      comp_cursor(status_win),
      comp_spaces(buf),
      comp_fileenconding(buf),
      comp_fileformat(buf),
      comp_filetype(buf),
    }

    if not status_active then
      return table.concat({
        "%#StatusLineNc#",
        "  ",
        "%=", -- Left/right separator
        table.concat(right, "   "),
        " ",
      })
    end

    local comp_mode_search_macro = function()
      local search = comp_search(buf)
      local macro = comp_macro()
      if not is_empty(search) then
        return search
      elseif not is_empty(macro) then
        return macro
      end
      return comp_mode()
    end

    return table.concat({
      "%#StatusLine#",
      "  ",
      comp_git_info(buf),
      "  ",
      comp_diag(buf),
      "  ",
      comp_mode_search_macro(),
      " ",
      comp_server(),
      "%=", -- Left/right separator
      table.concat(right, "   "),
      " ",
    })
  end,
}
