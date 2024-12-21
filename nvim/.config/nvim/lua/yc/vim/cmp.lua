local cmp = {}

cmp.visible = function()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then
    return blink.is_visible()
  end

  ---@module 'cmp'
  local nvim_cmp = package.loaded["cmp"]
  if nvim_cmp then
    return nvim_cmp.core.view:visible()
  end

  return false
end

cmp.hide = function()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then
    require("blink.cmp").hide()
    return
  end

  ---@module 'cmp'
  local nvim_cmp = package.loaded["cmp"]
  if nvim_cmp then
    if nvim_cmp.visible() then
      nvim_cmp.abort()
    end
    return
  end
end

cmp.snippet = {
  try_stop = function()
    vim.snippet.stop()
  end,
}

YcVim.cmp = cmp
