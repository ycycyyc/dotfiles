---@class YcVim.env
local env = {
  clangd_bin = "clangd", -- {path}
  cpp_debug_mode = "vscode", -- vscode or lldb
  go_debug_mode = "dlv", -- dlv or vscode
  ts = true,
  treesitter_textobj = true,
  semantic_token = true,
  coc = false,
  winbar = true,
  inlayhint = true,
  git = "neogit",
  noice = false,
  usePlaceholders = true,
  cmp_ghost_text = true,
  snippet = "native",
  cmp = "blink",
  pick = "snacks",
}

local json_conf = vim.env.NVIM_JSON_CONF or "{}"
env = vim.tbl_deep_extend("force", env, vim.json.decode(json_conf))

if not env.ts then
  if env.coc then
    vim.g.custom_define_highlight = 1
  end
else
  vim.opt.syntax = "off"
end

return env
