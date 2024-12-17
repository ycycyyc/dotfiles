YcVim.cmp = {}

YcVim.cmp.visible = function()
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

YcVim.cmp.hide = function()
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

YcVim.cmp.snippet = {
  try_stop = function()
    vim.snippet.stop()
  end,
}
