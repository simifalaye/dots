return {
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = "BufRead",
    config = function()
      local indentscope = require("mini.indentscope")
      indentscope.setup({
        draw = {
          delay = 0,
          animation = indentscope.gen_animation.none(),
        },
        -- Which character to use for drawing scope indicator
        -- alternative styles: ┆ ┊ ╎
        symbol = "╎",
      })
    end,
  },
  {
    "echasnovski/mini.surround",
    version = false,
    event = "BufRead",
    config = function()
      local surround = require("mini.surround")
      surround.setup({
        mappings = {
          find = "",
          find_left = "",
          update_n_lines = "",
        },
        -- Number of lines within which surrounding is searched
        n_lines = 62,
        -- How to search for surrounding (first inside current line, then inside
        -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
        -- 'cover_or_nearest'. For more details, see `:h MiniSurround.config`.
        search_method = "cover_or_next",
      })
    end,
  },
}
