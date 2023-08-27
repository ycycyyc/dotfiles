return {
  ft = { "lua", "python", "json" },
  config = function()
    local ft = require "guard.filetype"

    ft("lua"):fmt "stylua"

    ft("python"):fmt {
      cmd = "black",
      args = { "-q", "-" },
      stdin = true,
    }

    ft("json"):fmt {
      cmd = "jq",
      stdin = true,
    }

    require("guard").setup {
      fmt_on_save = false,
      lsp_as_default_formatter = false,
    }
  end,
}
