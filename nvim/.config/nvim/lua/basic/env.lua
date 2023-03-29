local M = {
  -- public
  clangd_bin = "clangd", -- {path}
  theme = "default", -- default
  lua_ls_bin = "lua-language-server", -- {path}
  lua_ls_root = "", --{dir}
  cpp_debug_mode = "vscode", -- vscode or lldb
  go_debug_mode = "dlv", -- dlv or vscode

  -- private
  neogit = "off", -- on or off
  line = "", -- "" or "lualine"
  fzf_lua = "off", -- on or off
  treesitter_textobj = "off", -- on or off
}
-- export NVIM_CONF="neogit=off,clangd_bin=clangd,theme=default,lua_ls_root=dir,lua_ls_bin=path"
--
M.setup = function()
  local conf = vim.env.NVIM_CONF
  local pairs = vim.fn.split(conf, ",")
  for _, elem in ipairs(pairs) do
    local opt = vim.fn.split(elem, "=")
    M[opt[1]] = opt[2]
  end
end

M.load_neogit = function()
  if M.neogit == "on" then
    return true
  end
  return false
end

M.load_fugitive = function()
  if M.load_neogit() == true then
    return false
  else
    return true
  end
end

M.load_lualine = function()
  if M.line == "lualine" then
    return true
  end
  return false
end

M.load_fzf_lua = function()
  if M.fzf_lua == "on" then
    return true
  end
  return false
end

return M
