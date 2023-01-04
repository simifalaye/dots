return {
  {
    "numToStr/Comment.nvim",
    tag = "v0.6",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
      { "g>", mode = { "n", "v" } },
      { "g<", mode = { "n", "v" } },
    },
    config = function()
      require("Comment").setup({})
    end,
  },
}
