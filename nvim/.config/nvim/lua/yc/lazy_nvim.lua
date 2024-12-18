local lazypath = function()
  local path = "lazy"

  if YcVim.env.coc then
    path = path .. "_coc"
  end

  path = path .. "_" .. YcVim.env.snippet .. "_" .. YcVim.env.cmp
  return vim.fn.stdpath "data" .. "/" .. path .. "/lazy.nvim"
end

-- stylua: ignore
local plugin_names = {
  "plenary", "oil", "flash", "fugitive", "gitdiff", "nvim-surround",
  "snacks", "comment", "grug", "substitute", "debug", "tree_sitter",
}

-- stylua: ignore
local lsp_plugin_names = {
  "fzf_lua", "lsp", "winbar", "gotest", "autopairs",
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
for i, name in ipairs(plugin_names) do
  table.insert(plugins, require("plugin." .. name))
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
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
