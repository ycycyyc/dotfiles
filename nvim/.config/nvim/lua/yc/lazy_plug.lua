local keys = require "basic.keys"
local env = require("basic.env").env
local lazy_keys = require("utils.helper").lazy_keys
local lazy_cmds = require("utils.helper").lazy_cmds

local M = {}

local lazypath = function()
  if env.coc then
    return vim.fn.stdpath "data" .. "/lazy_coc/lazy.nvim"
  else
    return vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
  end
end

local basic_plugins = {
  "nvim-lua/plenary.nvim",

  {
    "folke/flash.nvim",
    keys = lazy_keys("plugin.flash", { "/", "?" }),
    config = require("plugin.flash").config,
  },

  {
    "NeogitOrg/neogit",
    keys = lazy_keys "plugin.neogit",
    init = require("plugin.neogit").init,
    config = require("plugin.neogit").config,
  },

  {
    "FabijanZulj/blame.nvim",
    keys = lazy_keys "plugin.gitblame",
    config = require("plugin.gitblame").config,
  },

  {
    "sindrets/diffview.nvim",
    keys = lazy_keys "plugin.gitdiff",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles" },
    config = require("plugin.gitdiff").config,
  },

  {
    "kylechui/nvim-surround",
    keys = require("plugin.nvim-surround").keys,
    opts = require("plugin.nvim-surround").opts,
  },

  {
    "akinsho/toggleterm.nvim",
    keys = { { keys.toggle_term } },
    config = require("plugin.term").config,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "x", "n" } },
      { "gcc", mode = { "n" } },
    },
    opts = {},
    -- 0.10版本自动注释功能不好用
    -- cond = vim.fn.has "nvim-0.10" == 0,
  },

  {
    "nvim-pack/nvim-spectre",
    keys = lazy_keys "plugin.find_and_replace",
    config = require("plugin.find_and_replace").config,
  },

  {
    "rcarriga/nvim-dap-ui",
    keys = { { keys.dbg_breakpoint } },
    config = require("plugin.debug").config,
    dependencies = { "mfussenegger/nvim-dap", "theHamsta/nvim-dap-virtual-text" },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "VeryLazy" },
    config = require("plugin.tree_sitter").config,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-context",
        config = require("plugin.tree_sitter").context_config,
        cond = false, -- disable now
      },
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = require("plugin.tree_sitter").textobj_config,
        cond = env.treesitter_textobj,
      },
    },
    cond = env.ts,
  },

  {
    "gbprod/substitute.nvim",
    keys = lazy_keys "plugin/substitute",
    config = require("plugin/substitute").config,
  },
}

local coc_plugins = {
  {
    "antoinemadec/coc-fzf",
    branch = "master",
    config = require("plugin.coc_fzf").config,
    dependencies = {
      {
        "neoclide/coc.nvim",
        branch = "release",
        config = require("plugin.coc").config,
      },
      {
        "junegunn/fzf.vim",
        event = "VeryLazy",
        config = require("plugin.fzf").config,
        dependencies = {
          "junegunn/fzf",
        },
      },
    },
  },
}

local lsp_plugins = {
  {
    "kyazdani42/nvim-tree.lua",
    keys = lazy_keys "plugin.tree",
    config = require("plugin.tree").config,
    cond = not env.minifiles,
  },

  {
    "echasnovski/mini.files",
    version = "*",
    keys = lazy_keys "plugin.mini",
    config = require("plugin.mini").config,
    cond = env.minifiles,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "CursorHold", "CursorHoldI" },
    config = require("plugin.git").config,
  },

  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = require("plugin.autopairs").config,
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },

  {
    "ycycyyc/fzf-lua",
    keys = lazy_keys "plugin.fzf_lua",
    cmd = lazy_cmds("plugin.fzf_lua", { "FzfLua" }),
    config = require("plugin.fzf_lua").config,
    init = require("plugin.fzf_lua").override_lsp_func,
    cond = env.fzf_lua,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = require("plugin.lsp").config,
    dependencies = "hrsh7th/cmp-nvim-lsp",
  },

  {
    "utilyre/barbecue.nvim",
    event = "VeryLazy",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      event = "VeryLazy",
      opts = {
        lazy_update_context = true,
      },
    },
    config = require("plugin.winbar").config,
    cond = env.winbar,
  },

  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = lazy_keys "plugin.symbol",
    config = require("plugin.symbol").config,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = require("plugin.cmp").config,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
    },
  },

  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    config = require("plugin.lsp").rust_config,
  },

  {
    "mhartington/formatter.nvim",
    ft = require("plugin.format").ft,
    config = require("plugin.format").config,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = require("plugin.noice").config,
    cond = env.noice,
  },
}

M.setup = function()
  vim.g.coc_data_home = "~/.config/coc_fzf/"

  local plugins = basic_plugins

  if env.coc then
    for _, plug in ipairs(coc_plugins) do
      table.insert(plugins, plug)
    end
  else
    for _, plug in ipairs(lsp_plugins) do
      table.insert(plugins, plug)
    end

    local snippet_plugins = require("plugin.snippet").plugins
    for _, plug in ipairs(snippet_plugins) do
      table.insert(plugins, plug)
    end
  end

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
