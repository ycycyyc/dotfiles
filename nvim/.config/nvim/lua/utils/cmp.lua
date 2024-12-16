local M = {}

function M.lsp_capabilities()
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

function M.visible()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then
    return blink.is_visible()
  end

  ---@module 'cmp'
  local cmp = package.loaded["cmp"]
  if cmp then
    return cmp.core.view:visible()
  end

  return false
end

function M.hide()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then
    require("blink.cmp").hide()
    return
  end

  ---@module 'cmp'
  local cmp = package.loaded["cmp"]
  if cmp then
    if cmp.visible() then
      cmp.abort()
    end
    return
  end
end

return M
