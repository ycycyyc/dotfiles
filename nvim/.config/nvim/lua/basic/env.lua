local M = {
  env = {},
}

local env = {
  clangd_bin = "clangd", -- {path}
  cpp_debug_mode = "vscode", -- vscode or lldb
  go_debug_mode = "dlv", -- dlv or vscode

  lualine = false,
  fzf_lua = true,
  ts = true,
  treesitter_textobj = true,
  semantic_token = true,
  luasnip = false,
  coc = false,
  telescope = true,
  python3 = "",
  winbar = true,
  inlayhint = false, -- wait for nvim0.10 stable version
  noice = false,
  usePlaceholders = true,
  cmp_ghost_text = true,
}

M.setup = function()
  if vim.fn.has "nvim-0.9" == 1 then
    local json_conf = vim.env.NVIM_JSON_CONF or "{}"
    M.env = vim.tbl_extend("force", env, vim.json.decode(json_conf))
  else
    M.env = env
  end

  if vim.fn.has "nvim-0.10" == 0 and M.env.inlayhint then
    M.env.inlayhint = false
    print "inlay hint only used in nvim-0.10"
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
