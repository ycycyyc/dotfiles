local M = {}

local ts_disable = function(lang, bufnr)
  if vim.tbl_contains({ "cpp", "go" }, lang) then
    return false
  end

  return vim.api.nvim_buf_line_count(bufnr) > 3500
end

M.config = function()
  local ensure_installed = { "cpp", "go", "lua", "c" }
  if vim.fn.has "mac" == 1 then
    ensure_installed = { "cpp", "go" }
  end

  require("nvim-treesitter.configs").setup {
    ensure_installed = ensure_installed, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    highlight = {
      enable = true, -- false will disable the whole extension
      disable = ts_disable,
      additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = true,
      disable = ts_disable,
      keymaps = {
        init_selection = "<TAB>",
        node_incremental = "<TAB>",
        node_decremental = "<S-TAB>",
        -- scope_incremental = "<TAB>",
      },
    },
  }
end

M.textobj_config = function()
  require("nvim-treesitter.configs").setup {
    textobjects = {
      move = {
        enable = true,
        disable = ts_disable,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]f"] = "@function.outer",
          ["]s"] = "@class.outer",
          ["]a"] = "@parameter.inner",
        },
        goto_next_end = {
          ["]F"] = "@function.outer",
          ["]S"] = "@class.outer",
          ["]A"] = "@parameter.inner",
        },
        goto_previous_start = {
          ["[f"] = "@function.outer",
          ["[s"] = "@class.outer",
          ["[a"] = "@parameter.inner",
        },
        goto_previous_end = {
          ["[F"] = "@function.outer",
          ["[S"] = "@class.outer",
          ["[A"] = "@parameter.inner",
        },
      },
      select = {
        enable = true,
        disable = ts_disable,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["as"] = "@class.outer",
          ["is"] = "@class.inner",
          ["ia"] = "@parameter.inner",
          ["aa"] = "@parameter.outer",
        },
      },
    },
  }
end

M.context_config = function()
  require("treesitter-context").setup {
    enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
      -- For all filetypes
      -- Note that setting an entry here replaces all other patterns for this entry.
      -- By setting the 'default' entry below, you can control which nodes you want to
      -- appear in the context window.
      default = {
        "class",
        "function",
        "method",
        "for", -- These won't appear in the context
        "while",
        "if",
        "switch",
        "case",
      },
      -- Example for a specific filetype.
      -- If a pattern is missing, *open a PR* so everyone can benefit.
      --   rust = {
      --       'impl_item',
      --   },
    },
    exact_patterns = {
      -- Example for a specific filetype with Lua patterns
      -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
      -- exactly match "impl_item" only)
      -- rust = true,
    },

    -- [!] The options below are exposed but shouldn't require your attention,
    --     you can safely ignore them.

    zindex = 20, -- The Z-index of the context window
    mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
    separator = nil, -- Separator between context and content. Should be a single character string, like '-'.
  }
end
return M
