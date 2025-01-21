---@alias YcVim.Setup.Initfunc [string|string[], function]
---@alias YcVim.Setup.Keymap [string|string[], string, string|function, vim.keymap.set.Opts?]
---@alias YcVim.Setup.Usercmd [string, function|string, vim.api.keyset.user_command]

---@class YcVim.SetupOpt
---@field user_cmds? YcVim.Setup.Usercmd[]
---@field keymaps? YcVim.Setup.Keymap[]
---@field initfuncs? YcVim.Setup.Initfunc[]

---@param user_cmds YcVim.Setup.Usercmd[]
local function setup_usercmd(user_cmds)
  for _, user_cmd in ipairs(user_cmds) do
    vim.api.nvim_create_user_command(user_cmd[1], user_cmd[2], user_cmd[3])
  end
end

---@param keymaps YcVim.Setup.Keymap[]
local function setup_keymaps(keymaps)
  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4])
  end
end

local group = vim.api.nvim_create_augroup("YcVim_setup_initfuncs", { clear = true })

---@param lang string
---@param initfunc function
local add_lang = function(lang, initfunc)
  local ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
  if ft == lang then
    initfunc()
  end

  vim.api.nvim_create_autocmd("FileType", { group = group, pattern = { lang }, callback = initfunc })
end

---@param initfunc YcVim.Setup.Initfunc
local add_langs = function(initfunc)
  local langs = initfunc[1]
  if type(langs) == "string" then
    langs = { langs }
  end

  local func = initfunc[2]

  for _, lang in ipairs(langs) do
    add_lang(lang, func)
  end
end

---@param initfuncs YcVim.Setup.Initfunc[]
local function setup_initfuncs(initfuncs)
  for _, initfunc in ipairs(initfuncs) do
    add_langs(initfunc)
  end
end

---@param m YcVim.SetupOpt
local setup = function(m)
  if m.user_cmds then
    setup_usercmd(m.user_cmds)
  end

  if m.keymaps then
    setup_keymaps(m.keymaps)
  end

  if m.initfuncs then
    setup_initfuncs(m.initfuncs)
  end
end

return setup
