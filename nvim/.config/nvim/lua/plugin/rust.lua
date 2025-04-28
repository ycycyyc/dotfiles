local config = function()
  vim.g.rustaceanvim = {
    tools = {
      code_actions = {
        ui_select_fallback = true,
      },
    },
    server = {
      on_attach = function(_, bufnr)
        YcVim.lsp.buf_map(bufnr)
      end,
    },
  }
end

return {
  "mrcjkb/rustaceanvim",
  ft = "rust",
  config = config,
}
