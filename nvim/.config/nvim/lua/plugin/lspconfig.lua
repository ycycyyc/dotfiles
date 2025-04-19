-- install lsp-server from
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local env = YcVim.env

return {
  "neovim/nvim-lspconfig",
  event = "User FilePost",
  config = function()
    local lspconfig = require "lspconfig"
    local configs = require "lspconfig.configs"

    if not configs.emmylua_ls then
      local root_files = {
        ".luarc.json",
        ".luarc.jsonc",
        ".emmyrc.json",
        ".git",
      }

      local util = require "lspconfig.util"

      configs.emmylua_ls = {
        default_config = {
          cmd = { "emmylua_ls" },
          filetypes = { "lua" },
          root_dir = util.root_pattern(root_files),
        },
      }
    else
      vim.notify "emmylua_ls is added in nvim-lspconfig"
    end

    for name, opt in pairs(YcVim.lsp.servers) do
      lspconfig[name].setup(vim.tbl_deep_extend("error", opt, {
        on_init = function(client, _)
          if client.server_capabilities and not env.semantic_token then
            client.server_capabilities.semanticTokensProvider = false
          end
        end,
        capabilities = YcVim.lsp.capabilities(name),
      }))
    end
  end,
}
