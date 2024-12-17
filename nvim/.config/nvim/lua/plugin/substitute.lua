return {
  "gbprod/substitute.nvim",
  keys = {
    {
      "<leader>x",
      function()
        require("substitute.exchange").operator()
      end,
    },
    {
      "<leader>xc",
      function()
        require("substitute.exchange").cancel()
      end,
    },
    {
      "X",
      function()
        require("substitute.exchange").visual()
      end,
      mode = "x",
    },
  },
  opts = {
    exchange = {
      motion = false,
      use_esc_to_cancel = false,
    },
  },
}
