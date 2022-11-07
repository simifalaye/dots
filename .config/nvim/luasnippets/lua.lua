---@diagnostic disable: undefined-global
return {
  snippet({
    trig = "mod",
    name = "Define module",
    dscr = "Template for a new module",
  }, {
    t({
      "local M = {}",
      "",
      "M.init = function()",
      "end",
      "",
      "return M",
    }),
  }),
}
