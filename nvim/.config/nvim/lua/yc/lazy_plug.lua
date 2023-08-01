local keys = require "basic.keys"
local env = require("basic.env").env

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
    "ycycyyc/flash.nvim",
    branch = "main",
    event = "VeryLazy",
    opts = require("plug_conf.move").flash_opts,
    keys = {
      {
        "<c-g>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
      {
        keys.jump,
        mode = { "n", "x", "o" },
        function()
          require("flash").jump {
            label = {
              after = false, ---@type boolean|number[]
              -- before = { 0, 0 },
              before = true,
            },
          }
        end,
        desc = "Flash",
      },
    },
  },

  {
    "tpope/vim-fugitive",
    keys = { keys.git_blame, keys.git_status },
    cmd = { "Gw" },
    config = require("plug_conf.git").fugitive_config,
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
    event = { "InsertEnter", "CursorHold", "CursorHoldI" },
    opts = {},
  },

  {
    "akinsho/toggleterm.nvim",
    keys = { { keys.toggle_term } },
    config = require("plug_conf.term").config,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "v" } },
      { "gcc", mode = { "n" } },
    },
    opts = {},
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
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "CursorHold", "CursorHoldI" },
    config = require("plug_conf.git").config,
  },

  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = function()
      local npairs = require "nvim-autopairs"
      npairs.setup { map_c_w = true }
      local cmp_autopairs = require "nvim-autopairs.completion.cmp"
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())

      local cj = function()
        if vim.fn.pumvisible() ~= 0 then
          return npairs.esc "<c-j>" .. npairs.autopairs_cr()
        else
          return npairs.autopairs_cr()
        end
      end
      vim.keymap.set("i", "<c-j>", cj, { expr = true, noremap = true })
    end,
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
    event = "VeryLazy",
    config = require("plug_conf.fzf_lua").config,
    cond = env.fzf_lua,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufAdd", "BufNewFile" },
    config = require("plug_conf.lsp").load_lsp_config,
  },

  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      opts = {
        lazy_update_context = true,
      },
    },
    config = require("plug_conf.winbar").config,
    cond = env.winbar,
  },

  {
    "simrat39/symbols-outline.nvim",
    keys = { { keys.toggle_symbol } },
    config = require("plug_conf.symbol").config,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = require("plug_conf.cmp").config,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-buffer",

      {
        "L3MON4D3/LuaSnip",
        config = function()
          if env.luasnip then
            -- vscode snippets path
            -- local snip_path = vim.fs.dirname(lazypath) .. "/friendly-snippets"
            -- require("luasnip.loaders.from_vscode").lazy_load { paths = { snip_path } }
            -- require "plug_conf.luasnip"
          end
        end,
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
        },
        cond = env.luasnip,
      },

      {
        "dcampos/nvim-snippy",
        dependencies = {
          "dcampos/cmp-snippy",
        },
        cond = not env.luasnip,
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

  { "wesleimp/stylua.nvim", ft = "lua" },

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
  local bplugins = {}

  if env.coc then
    bplugins = coc_plugins
  else
    bplugins = lsp_plugins
  end

  for _, plug in ipairs(bplugins) do
    table.insert(plugins, plug)
  end

  if not vim.loop.fs_stat(lazypath()) then
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
