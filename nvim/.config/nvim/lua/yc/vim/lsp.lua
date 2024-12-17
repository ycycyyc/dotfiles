YcVim.lsp = {}

YcVim.lsp.lsp_capabilities = function()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then
    return blink.get_lsp_capabilities()
  end

  ---@module 'cmp_nvim_lsp'
  local cmp_nvim_lsp = package.loaded["cmp_nvim_lsp"]
  if cmp_nvim_lsp then
    return require("cmp_nvim_lsp").default_capabilities()
  end
end

local function sync_format_save()
  vim.lsp.buf.format { async = false }
  vim.cmd "silent write"
end

YcVim.lsp.method = {
  -- 默认方法, 后续会被插件覆盖（fzf-lua)
  definition = vim.lsp.buf.definition,
  references = vim.lsp.buf.references,
  impl = vim.lsp.buf.implementation,
  code_action = vim.lsp.buf.code_action,
  format = sync_format_save,
  plugin_format = function()
    vim.notify "not support now"
  end, --插件格式化
}
