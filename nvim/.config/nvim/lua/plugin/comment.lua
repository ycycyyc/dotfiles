return {
  "numToStr/Comment.nvim",
  keys = {
    { "gc", mode = { "x", "n" } },
    { "gcc", mode = { "n" } },
  },
  opts = {},
  -- 0.10版本自动注释功能不好用
  -- cond = vim.fn.has "nvim-0.10" == 0,
}
