local lazypath = function()
  local path = "lazy_" .. YcVim.env_hash
  return vim.fn.stdpath "data" .. "/" .. path .. "/lazy.nvim"
end

-- stylua: ignore
local plugin_names = {
  "plenary", "oil", "flash", "git_manager", "gitdiff", "nvim-surround", "junegunn_fzf",
  "snacks", "comment", "grug", "substitute", "debug", "tree_sitter", "icon",
}

-- stylua: ignore
local lsp_plugin_names = {
  "pick", "lspconfig", "winbar", "gotest", "autopairs",
  "gitsigns", "rust", "format", "symbol", "code", "snippet",
}

if YcVim.env.coc then
  table.insert(plugin_names, "coc_fzf")
else
  for _, name in ipairs(lsp_plugin_names) do
    table.insert(plugin_names, name)
  end
end

local plugins = {}
for _, name in ipairs(plugin_names) do
  local pn = require("plugin." .. name)

  if type(pn[1]) == "string" then
    table.insert(plugins, pn)
  else
    for _, p in ipairs(pn) do
      table.insert(plugins, p)
    end
  end
end

vim.g.coc_data_home = "~/.config/coc_fzf/"

local uv = vim.loop or vim.uv

if not uv.fs_stat(lazypath()) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath(),
  }
end

vim.opt.rtp:prepend(lazypath())
require("lazy").setup(plugins, {
  root = vim.fs.dirname(lazypath()),
  performance = {
    rtp = {
      ---@type string[] list any plugins you want to disable here
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        -- "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
  },
})
