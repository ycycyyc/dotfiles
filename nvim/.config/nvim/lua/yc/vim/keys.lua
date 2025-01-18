-- 常用 快捷键
---@class YcVim.keys
local keys = {
  -- search
  pick_open = "<leader>o",
  pick_grep = "<leader>f", -- search use rg and fzf
  pick_lines = "<leader>b", -- search only in buffer use fzf
  pick_files = "<C-p>", -- 查文件
  pick_grep_word = "gw",
  pick_grep_word_cur_buf = "gW",
  pick_resume = "<leader>l",
  -- pick_buffers = "<leader>o", -- buffers 切换
  pick_cmd_history = "<leader>H",

  global_find_and_replace = "<leader>rr",
  buffer_find_and_replace = "<leader>R",

  -- op
  toggle_dir = "<Leader>n", -- 打开目录树
  toggle_dir_open_file = "<leader>N",
  toggle_symbol = "<Leader>t", -- symbol
  switch_source_header = "<Leader>c", -- cpp h 文件切换
  jump = "<Leader>e", -- 跳转
  select_ts = "<leader>v",
  --term
  toggle_term = "<C-t>", -- 打开/关闭内置终端
  toggle_mouse = "<leader>A",
  -- jump
  jump_to_next_qf = "]e",
  jump_to_prev_qf = "[e",

  -- lsp
  lsp_goto_declaration = "gD", -- 声明
  lsp_goto_definition = "gd", -- 定义
  lsp_goto_type_definition = "gy", -- 类型
  lsp_goto_references = "gr", -- 引用
  lsp_hover = "K", -- hover
  lsp_impl = "<leader>i", -- 实现
  lsp_rename = "<leader>rn", -- 变量重命名
  lsp_signature_help = "<C-l>",
  lsp_range_format = "f", -- 范围格式化
  lsp_format = "<leader><leader>", -- 格式化
  lsp_code_action = "<leader>d", -- 代码修复提示
  lsp_err_goto_prev = "[g", -- 上个错误
  lsp_err_goto_next = "]g", -- 下个错误
  lsp_finder = "<A-d>",
  lsp_toggle_autoformat = "<leader>T",
  lsp_toggle_inlay_hint = "<leader>a",
  lsp_symbols = "<leader>s",
  lsp_global_symbols = "<leader>S",

  -- debug 调试
  dbg_breakpoint = "<F1>",
  dbg_continue = "<F4>",
  dbg_step_over = "<F8>",
  dbg_step_into = "<F7>",
  dbg_eval = "<F5>",

  -- git
  git_status = "<leader>g",
  git_next_chunk = "]c",
  git_prev_chunk = "[c",
  git_commits = "<leader>hh",
  git_reset_chunk = "<leader>hu",
  git_preview_hunk = "<leader>hp",
  git_blame = "<leader>hl",
  git_diff = "<leader>hd",
  git_diff_open = "<leader>ho",
  git_diff_file = "<leader>hf",
}

keys.buf_map = function(mode, key, action)
  vim.keymap.set(mode, key, action, { noremap = true, buffer = true, silent = true })
end

return keys
