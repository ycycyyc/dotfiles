local config = function()
  local keys = YcVim.keys
  local attach_conf = {
    keymaps = {
      [keys.lsp_code_action] = { ":RustLsp codeAction<cr>" },
      [keys.lsp_hover] = { ":RustLsp hover actions<cr>" },
    },
  }

  vim.g.rustaceanvim = {
    tools = {
      code_actions = {
        ui_select_fallback = true,
      },
    },
    server = {
      on_attach = function(client, bufnr)
        YcVim.lsp.on_attach(attach_conf, client, bufnr)
      end,
    },
  }
end

return {
  "mrcjkb/rustaceanvim",
  ft = "rust",
  config = config,
}
