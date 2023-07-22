-- 常用 快捷键
return {
  -- search
  search_global = "<Leader>f", -- search use rg and fzf
  run_find = "<Leader>F",
  search_toggle_rg_mode = "<leader>T", -- 使用fixString 匹配还是 正则
  search_buffer = "<Leader>b", -- search only in buffer use fzf
  search_find_files = "<C-p>", -- 查文件
  search_cur_word = "gw",
  search_cur_word_cur_buf = "gW",
  search_resume = "<leader>l",
  switch_buffers = "<leader>o", -- buffers 切换
  global_find_and_replace = "<leader>R",
  buffer_find_and_replace = "<leader>S",

  -- op
  toggle_dir = "<Leader>n", -- 打开目录树
  toggle_dir_open_file = "<leader>N",
  toggle_symbol = "<Leader>t", -- symbol
  switch_source_header = "<Leader>c", -- cpp h 文件切换
  jump = "<Leader>e", -- 跳转
  --term
  toggle_term = "<C-t>", -- 打开/关闭内置终端
  -- jump
  jump_to_next_qf = "<leader>j",
  jump_to_prev_qf = "<leader>k",

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
  lsp_incoming_calls = "gl",
  lsp_toggle_autoformat = "<leader>T",

  -- debug 调试
  dbg_breakpoint = "<F1>",
  dbg_continue = "<F4>",
  dbg_step_over = "<F8>",
  dbg_step_into = "<F7>",
  dbg_eval = "<F5>",

  -- git
  git_commits = "<leader>C",
  git_next_chunk = "]c",
  git_prev_chunk = "[c",
  git_reset_chunk = "<leader>hu",
  git_preview_hunk = "<leader>hp",
  git_status = "<leader>g",
  git_blame = "<leader>hl",
  git_diff = "<leader>hd",
  git_diff_open = "<leader>ho",
  git_diff_file = "<leader>hf",
}
