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
  neogit = false,
  fzf_lua = false,
  treesitter_textobj = false,
  semantic_token = false,
  luasnip = false,
  coc = false,
  coclist = false,
}

M.setup = function()
  if vim.fn.has "nvim-0.9" == 1 then
    local json_conf = vim.env.NVIM_JSON_CONF or "{}"
    M.env = vim.tbl_extend("force", env, vim.json.decode(json_conf))
  else
    M.env = env
  end

  if M.env.semantic_token then
    vim.g.custom_define_highlight = 1
  end
end

return M
