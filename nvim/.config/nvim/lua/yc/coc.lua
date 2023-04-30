local keys = require "basic.keys"
local env = require("basic.env").env
local lazypath = vim.fn.stdpath "data" .. "/lazy_coc/lazy.nvim"

local M = {}

local plugins = {
  {
    "ggandor/leap.nvim",
    keys = { { keys.jump } },
    config = require("plug_conf.move").config,
  },

  {
    "tpope/vim-fugitive",
    keys = { keys.git_blame, keys.git_status },
    cmd = { "Gw" },
    config = require("plug_conf.git").fugitive_config,
    cond = not env.neogit,
  },

  {
    "akinsho/toggleterm.nvim",
    keys = { { keys.toggle_term } },
    config = require("plug_conf.term").config,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gcc", mode = { "n", "v" } },
    },
    opts = {},
  },

  {
    "antoinemadec/coc-fzf",
    branch = "release",
    config = require("plug_conf.coc").fzf_config,
    dependencies = {
      {
        "neoclide/coc.nvim",
        branch = "release",
        config = require("plug_conf.coc").coc_config,
      },
      {
        "junegunn/fzf.vim",
        event = "VeryLazy",
        config = require("plug_conf.fzf").config,
        dependencies = {
          "junegunn/fzf",
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "VeryLazy" },
    config = require("plug_conf.tree_sitter").config,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-context",
        config = require("plug_conf.tree_sitter").context_config,
        cond = false, -- disable now
      },
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = require("plug_conf.tree_sitter").textobj_config,
        cond = env.treesitter_textobj,
      },
    },
  },
}

M.setup = function()
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    }
  end

  vim.opt.rtp:prepend(lazypath)
  require("lazy").setup(plugins, {
    root = vim.fn.stdpath "data" .. "/lazy_coc",
    performance = {
      rtp = {
        ---@type string[] list any plugins you want to disable here
        disabled_plugins = {
          "gzip",
          -- "matchit",
          -- "matchparen",
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          -- "tutor",
          "zipPlugin",
        },
      },
    },
    ui = {
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
end

return M
