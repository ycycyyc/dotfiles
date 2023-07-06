local M = {}

M.config = function()
  local opts = {
    cmdline = {
      enabled = true, -- enables the Noice cmdline UI
      view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
      opts = {}, -- global options for the cmdline. See section on views
      ---@type table<string, CmdlineFormat>
      format = {
        -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
        -- view: (default is cmdline view)
        -- opts: any options passed to the view
        -- icon_hl_group: optional hl_group for the icon
        -- title: set to anything or empty string to hide
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = "/", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = "?", lang = "regex" },
        filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
        lua = false,
        help = false,
        input = {}, -- Used by input()
        -- lua = false, -- to disable a format, set to `false`
      },
    },
  }

  require("noice").setup(opts)

  vim.cmd [[
      set laststatus=0
      hi! link StatusLine Normal
      hi! link StatusLineNC Normal
      set statusline=%{repeat('─',winwidth('.'))}
  ]]
end

return M
