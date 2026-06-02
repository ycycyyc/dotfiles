return {
  "coder/claudecode.nvim",
  config = true,
  lazy = false,
  opts = {
    terminal_cmd = "claude-internal --continue 2>/dev/null || claude-internal",
  },
  keys = {
    {
      "<leader>C",
      "<cmd>ClaudeCode<cr>",
      mode = { "n" },
      desc = "Toggle Claude",
    },
  },
}
