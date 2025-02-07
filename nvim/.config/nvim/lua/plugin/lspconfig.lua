-- install lsp-server from
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local env = YcVim.env

return {
  "neovim/nvim-lspconfig",
  event = "User FilePost",
  config = function()
    local lspconfig = require "lspconfig"

    for name, opt in pairs(YcVim.lsp.servers) do
      lspconfig[name].setup(vim.tbl_deep_extend("error", opt, {
        on_init = function(client, _)
          if client.server_capabilities and not env.semantic_token then
            client.server_capabilities.semanticTokensProvider = false
          end
        end,
        capabilities = YcVim.lsp.capabilities(),
      }))
    end
  end,
}
