return {
  {
    "numToStr/Comment.nvim",
    tag = "v0.6",
    keys = { "gc", "gb", "g>", "g<" },
    config = function()
      require("Comment").setup({})
    end,
  },
}
