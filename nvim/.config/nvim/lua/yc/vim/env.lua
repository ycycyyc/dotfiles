---@class YcVim.env
local env = {
  go_debug_mode = "dlv", -- dlv or vscode
  treesitter_textobj = true,
  semantic_token = true,
  winbar = true,
  inlayhint = true,
  usePlaceholders = true,
}

local json_conf = vim.env.NVIM_JSON_CONF or "{}"
env = vim.tbl_deep_extend("force", env, vim.json.decode(json_conf))

return env
