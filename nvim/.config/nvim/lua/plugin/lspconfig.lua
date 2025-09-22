-- install lsp-server from
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
return {
  "neovim/nvim-lspconfig",
  event = "User FilePost",
  config = function()
    local env = YcVim.env
    for name, opt in pairs(YcVim.lsp.servers) do
      vim.lsp.config(
        name,
        vim.tbl_deep_extend("error", opt, {
          on_init = function(client, _)
            if client.server_capabilities and not env.semantic_token then
              client.server_capabilities.semanticTokensProvider = false
            end
          end,
          capabilities = YcVim.lsp.capabilities(name),
        })
      )
      vim.lsp.enable(name)
    end
  end,
}
