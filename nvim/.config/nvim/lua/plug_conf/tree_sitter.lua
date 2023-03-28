local M = {}

M.config = function()
  local ensure_installed = { "cpp", "go", "lua", "c" }
  if vim.fn.has "mac" == 1 then
    ensure_installed = { "cpp", "go" }
  end

  require("nvim-treesitter.configs").setup {
    ensure_installed = ensure_installed, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = {
      "dart",
      "scala",
      "php",
      "rst",
      "svelte",
      "comment",
      "vim",
      "elm",
      "haskell",
      "typescript",
      "tsx",
      "tlaplus",
      "javascript",
    }, -- List of parsers to ignore installing
    highlight = {
      enable = true, -- false will disable the whole extension
      disable = { "dart", "scala" }, -- list of language that will be disabled
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<TAB>",
        -- scope_incremental = "<TAB>",
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
