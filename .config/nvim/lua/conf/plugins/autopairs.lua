local log = require("conf.utils.log")

local M = {}

M.def = {
  {
    "windwp/nvim-autopairs",
    after = "nvim-cmp",
  },
}

M.config = function()
  local prequire = require("conf.utils.prequire")
  local cmp = prequire("cmp")

  -- Make it work with cmp
  if cmp then
    log.debug("Setting up cmp with autopairs")
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on(
      "confirm_done",
      cmp_autopairs.on_confirm_done({ map_char = { tex = "" } })
    )
  end

  -- Setup plugin
  require("nvim-autopairs").setup({
    disable_in_macro = true,
    check_ts = true,
    ts_config = {
      lua = { "string", "source" },
      javascript = { "string", "template_string" },
      java = false,
    },
    disable_filetype = { "TelescopePrompt", "vim" },
    fast_wrap = {},
  })
end

return M
