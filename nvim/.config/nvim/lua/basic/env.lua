local M = {
  env = {},
}

local env = {
  clangd_bin = "clangd", -- {path}
  theme = "default", -- default
  lua_ls_bin = "lua-language-server", -- {path}
  lua_ls_root = "", --{dir}
  cpp_debug_mode = "vscode", -- vscode or lldb
  go_debug_mode = "dlv", -- dlv or vscode

  lualine = false,
  fzf_lua = true,
  ts = true,
  treesitter_textobj = false,
  semantic_token = false,
  luasnip = false,
  coc = false,
  python3 = "",
  winbar = true,
  inlayhint = true,
  noice = false,
}

M.setup = function()
  if vim.fn.has "nvim-0.9" == 1 then
    local json_conf = vim.env.NVIM_JSON_CONF or "{}"
    M.env = vim.tbl_extend("force", env, vim.json.decode(json_conf))
  else
    M.env = env
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
