local plugin = {}

local ts_disable = function(lang, bufnr)
  if vim.tbl_contains({ "cpp", "go" }, lang) then
    return false
  end

  return vim.api.nvim_buf_line_count(bufnr) > 10000
end

plugin.config = function()
  local ensure_installed = { "cpp", "go", "lua", "c" }
  if vim.fn.has "mac" == 1 then
    ensure_installed = { "cpp", "go" }
  end

  require("nvim-treesitter.configs").setup {
    ensure_installed = ensure_installed,
    highlight = {
      enable = true,
      disable = ts_disable,
      additional_vim_regex_highlighting = false,
    },
  }
end

plugin.textobj_config = function()
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
        lookahead = true,

        keymaps = {
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

return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
  config = plugin.config,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      config = plugin.textobj_config,
      cond = YcVim.env.treesitter_textobj,
    },
  },
  lazy = vim.fn.argc(-1) == 0 and YcVim.env.pick ~= "snacks",
  cond = YcVim.env.ts,
}
