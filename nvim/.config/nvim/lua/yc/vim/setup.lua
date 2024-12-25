---@param user_cmds table
local function setup_usercmd(user_cmds)
  for _, user_cmd in ipairs(user_cmds) do
    vim.api.nvim_create_user_command(user_cmd[1], user_cmd[2], user_cmd[3])
  end
end

---@param keymaps table
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

---@param langs string | string[]
---@param initfunc function
local add_langs = function(langs, initfunc)
  if type(langs) == "string" then
    langs = { langs }
  end

  for _, lang in ipairs(langs) do
    add_lang(lang, initfunc)
  end
end

---@param initfuncs table
local function setup_initfuncs(initfuncs)
  for _, initfunc in ipairs(initfuncs) do
    add_langs(initfunc[1], initfunc[2])
  end
end

---@param m table
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
