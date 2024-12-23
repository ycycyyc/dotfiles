local env = {
  clangd_bin = "clangd", -- {path}
  cpp_debug_mode = "vscode", -- vscode or lldb
  go_debug_mode = "dlv", -- dlv or vscode
  ts = true,
  treesitter_textobj = true,
  semantic_token = true,
  coc = false,
  python3 = "",
  winbar = true,
  inlayhint = true,
  git = "neogit",
  noice = false,
  usePlaceholders = true,
  cmp_ghost_text = true,
  snippet = "native",
  cmp = "blink",
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

YcVim.env = env

local function calculateHash(str)
  local hash = 0
  local len = string.len(str)
  for i = 1, len do
    local byte = string.byte(str, i)
    hash = (hash * 31 + byte) % (2 ^ 32) -- 使用简单的哈希算法
  end
  return hash
end

YcVim.env_hash = calculateHash(vim.inspect(YcVim.env))
