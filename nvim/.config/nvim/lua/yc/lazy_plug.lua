-- load plugin
local keys = require "basic.keys"
local env = require "basic.env"
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

local M = {}

local plugins = {
  "nvim-lua/plenary.nvim",
  "kyazdani42/nvim-web-devicons",

  {
    "kyazdani42/nvim-tree.lua",
    keys = { {
      keys.toggle_dir,
      ":NvimTreeToggle<cr>",
    } },
    config = require("plug_conf.tree").config,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "CursorHold", "CursorHoldI" },
    config = require("plug_conf.git").config,
  },

  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    opts = {},
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
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose" },
    config = require("plug_conf.gitdiff").config,
  },

  {
    "ggandor/leap.nvim",
    keys = { { keys.jump } },
    config = require("plug_conf.move").config,
  },

  {
    "tpope/vim-surround",
    event = { "InsertEnter", "CursorHold", "CursorHoldI" },
    cond = true,
  },

  {
    "kylechui/nvim-surround",
    event = { "InsertEnter", "CursorHold", "CursorHoldI" },
    opts = {},
    cond = false,
  },

  { "tpope/vim-repeat", event = "VeryLazy", cond = true },

  {
    "tpope/vim-fugitive",
    keys = { keys.git_blame, keys.git_status },
    cmd = { "Gw" },
    config = function()
      vim.keymap.set("n", keys.git_blame, ":Git blame<cr>")
      vim.keymap.set("n", keys.git_status, ":G<space>")
    end,
    cond = env.load_fugitive,
  },

  {
    "TimUntersberger/neogit",
    keys = { keys.git_status },
    config = function()
      local neogit = require "neogit"
      neogit.setup {
        kind = "split_above",
        integrations = {
          diffview = true,
        },
      }
      vim.keymap.set("n", keys.git_status, ":Neogit<space>")
    end,
    cond = env.load_neogit,
  },

  {
    "junegunn/fzf.vim",
    event = "VeryLazy",
    config = require("plug_conf.fzf").config,
    dependencies = {
      "junegunn/fzf",
    },
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = require("plug_conf.lsp").load_lsp_config,
  },

  {
    "simrat39/symbols-outline.nvim",
    keys = { { keys.toggle_symbol } },
    config = require("plug_conf.symbol").config,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "CursorHold", "CursorHoldI" },
    config = require("plug_conf.tree_sitter").config,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      config = require("plug_conf.tree_sitter").context_config,
      cond = false, -- disable now
    },
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = require("plug_conf.cmp").config,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "onsails/lspkind-nvim",
    },
  },

  {
    "akinsho/toggleterm.nvim",
    keys = { { keys.toggle_term } },
    config = require("plug_conf.term").config,
  },

  {
    "ycycyyc/nvim-lspfuzzy",
    event = { "CursorHold", "CursorHoldI", "BufReadPost", "BufAdd", "BufNewFile" },
    config = require("plug_conf.lspfuzzy").config,
    dependencies = {
      "junegunn/fzf",
      "junegunn/fzf.vim",
    },
  },

  { "kevinhwang91/nvim-bqf", ft = "qf" },

  {
    "rcarriga/nvim-dap-ui",
    keys = { { keys.dbg_breakpoint } },
    config = require("plug_conf.debug").config,
    dependencies = { "mfussenegger/nvim-dap", "theHamsta/nvim-dap-virtual-text" },
  },

  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    config = require("plug_conf.lsp").rust_config,
  },

  { "wesleimp/stylua.nvim", ft = "lua" },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = require("plug_conf.line").config,
    cond = env.load_lualine,
  },

  {
    "nvim-pack/nvim-spectre",
    keys = {
      {
        keys.global_find_and_replace,
        function()
          require("spectre").open()
        end,
        desc = "replace global",
      },
      {
        keys.buffer_find_and_replace,
        function()
          require("spectre").open_file_search()
        end,
        desc = "replace only file",
      },
    },

    opts = require("plug_conf.find_and_replace").opts,
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
  require("lazy").setup(plugins)
end

return M
