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
    keys = {
      { "/" },
      { keys.jump },
      { keys.select_ts },
    },
    branch = "main",
    config = require("plug_conf.flash").config,
  },

  {
    "tpope/vim-fugitive",
    keys = { keys.git_blame, keys.git_status },
    cmd = { "Gw" },
    config = require("plug_conf.fugitive").config,
  },

  {
    "sindrets/diffview.nvim",
    keys = {
      { keys.git_diff, ":DiffOpen<cr>" },
      { keys.git_diff_open, ":DiffviewOpen<cr>" },
      { keys.git_diff_file },
    },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles" },
    config = require("plug_conf.gitdiff").config,
  },

  {
    "kylechui/nvim-surround",
    keys = {
      { "ds", mode = "n" },
      { "cs", mode = "n" },
      { "ys", mode = "n" },
      { "S", mode = "x" },
    },
    opts = {
      keymaps = {
        -- disable this keymap
        normal_cur = false,
        normal_line = false,
        normal_cur_line = false,

        insert = false,
        insert_line = false,

        visual_line = false,
        change_line = false,
      },
    },
  },

  {
    "akinsho/toggleterm.nvim",
    keys = { { keys.toggle_term } },
    config = require("plug_conf.term").config,
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
    keys = lazy_keys "plug_conf.find_and_replace",
    config = require("plug_conf.find_and_replace").config,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = require("plug_conf.line").config,
    cond = env.lualine,
  },

  {
    "rcarriga/nvim-dap-ui",
    keys = { { keys.dbg_breakpoint } },
    config = require("plug_conf.debug").config,
    dependencies = { "mfussenegger/nvim-dap", "theHamsta/nvim-dap-virtual-text" },
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
    cond = env.ts,
  },

  {
    "gbprod/substitute.nvim",
    keys = {
      { "<leader>x", mode = { "n" } },
      { "<leader>xc", mode = { "n" } },
      { "X", mode = { "x" } },
    },

    config = function()
      require("substitute").setup {
        exchange = {
          motion = false,
          use_esc_to_cancel = false,
        },
      }

      vim.keymap.set("n", "<leader>x", require("substitute.exchange").operator, { noremap = true })
      vim.keymap.set("x", "X", require("substitute.exchange").visual, { noremap = true })
      vim.keymap.set("n", "<leader>xc", require("substitute.exchange").cancel, { noremap = true })
    end,
  },
}

local coc_plugins = {
  {
    "antoinemadec/coc-fzf",
    branch = "master",
    config = require("plug_conf.coc_fzf").config,
    dependencies = {
      {
        "neoclide/coc.nvim",
        branch = "release",
        config = require("plug_conf.coc").config,
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
}

local lsp_plugins = {
  {
    "kyazdani42/nvim-tree.lua",
    keys = {
      {
        keys.toggle_dir,
        "<cmd>NvimTreeToggle<cr>",
      },
      {
        keys.toggle_dir_open_file,
        function()
          require("nvim-tree.api").tree.open { find_file = true }
        end,
      },
    },
    config = require("plug_conf.tree").config,
    cond = not env.minifiles,
  },

  {
    "echasnovski/mini.files",
    version = "*",
    keys = { {
      keys.toggle_dir,
    }, {
      keys.toggle_dir_open_file,
    } },
    config = require("plug_conf.mini").config,
    cond = env.minifiles,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "CursorHold", "CursorHoldI" },
    config = require("plug_conf.git").config,
  },

  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = require("plug_conf.autopairs").config,
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
  },

  {
    "junegunn/fzf.vim",
    event = "VeryLazy",
    config = require("plug_conf.fzf").config,
    dependencies = {
      "junegunn/fzf",
    },
    cond = not env.fzf_lua,
  },

  {
    "ibhagwan/fzf-lua",
    keys = lazy_keys "plug_conf.fzf_lua",
    cmd = lazy_cmds("plug_conf.fzf_lua", { "FzfLua" }),
    config = require("plug_conf.fzf_lua").config,
    init = require("plug_conf.fzf_lua").setup_lspkeymap,
    cond = env.fzf_lua,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = require("plug_conf.lsp").load_lsp_config,
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
    config = require("plug_conf.winbar").config,
    cond = env.winbar,
  },

  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { keys.toggle_symbol, "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    config = require("plug_conf.symbol").config,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = require("plug_conf.cmp").config,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",

      {
        "dcampos/nvim-snippy",
        opts = {
          mappings = {
            is = {
              ["<Tab>"] = "expand_or_advance",
              ["<S-Tab>"] = "previous",
            },
          },
        },
        dependencies = {
          "dcampos/cmp-snippy",
        },
      },
    },
  },

  {
    "ycycyyc/nvim-lspfuzzy",
    event = { "CursorHold", "CursorHoldI", "BufReadPost", "BufAdd", "BufNewFile" },
    config = require("plug_conf.lspfuzzy").config,
    dependencies = {
      "junegunn/fzf",
    },
    cond = not env.fzf_lua,
  },

  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    config = require("plug_conf.lsp").rust_config,
  },

  {
    "mhartington/formatter.nvim",
    ft = require("plug_conf.format").ft,
    config = require("plug_conf.format").config,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = require("plug_conf.noice").config,
    cond = env.noice,
  },
}

M.setup = function()
  vim.g.coc_data_home = "~/.config/coc_fzf/"

  local plugins = basic_plugins

  for _, plug in ipairs(env.coc and coc_plugins or lsp_plugins) do
    table.insert(plugins, plug)
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
