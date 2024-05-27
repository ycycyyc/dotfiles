local M = {
  env = {},
}

local env = {
  clangd_bin = "clangd", -- {path}
  cpp_debug_mode = "vscode", -- vscode or lldb
  go_debug_mode = "dlv", -- dlv or vscode
  minifiles = false,
  ts = true,
  treesitter_textobj = true,
  semantic_token = true,
  coc = false,
  python3 = "",
  winbar = true,
  inlayhint = true,
  noice = false,
  usePlaceholders = true,
  cmp_ghost_text = true,
  snippet = "",
}

M.setup = function()
  local json_conf = vim.env.NVIM_JSON_CONF or "{}"
  M.env = vim.tbl_deep_extend("force", env, vim.json.decode(json_conf))

  if vim.fn.has "nvim-0.10" == 0 and M.env.inlayhint then
    M.env.inlayhint = false
  end

  if not M.env.ts then
    if M.env.coc then
      vim.g.custom_define_highlight = 1
    end
  else
    vim.opt.syntax = "off"
  end
end

return M
