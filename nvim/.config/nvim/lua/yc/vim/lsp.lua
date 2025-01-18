---@class YcVim.lsp
local lsp = {}

local keys = YcVim.keys

---@alias YcVim.Keymaps table<string, table>

---@class YcVim.Lsp.Conf
---@field auto_format boolean
---@field keymaps YcVim.Keymaps

lsp.lsp_capabilities = function()
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

lsp.method = {
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

local apply_lsp_edit = function(resp)
  if resp and resp[1] then
    local result = resp[1].result
    if result then
      local uri = vim.uri_from_bufnr(0)
      local textDocument = { uri = uri, version = 0 }
      local edits = result
      local documentChanges = {}
      table.insert(documentChanges, { edits = edits, textDocument = textDocument })
      local change_list = { documentChanges = documentChanges }
      vim.lsp.util.apply_workspace_edit(change_list, "utf-8")
    end
  end
end

---@param pos number[]
local range_format = function(pos)
  local timeoutms = 1000 ---@type number
  local para = vim.lsp.util.make_given_range_params()

  local startp, endp = pos[1], pos[2]
  if startp > endp then
    startp, endp = pos[2], pos[1]
  end

  local range = {
    start = {
      line = startp - 1,
      character = 0,
    },
  }
  range["end"] = {
    line = endp - 1,
    character = 0,
  }
  para.range = range

  -- 退出可视模式
  YcVim.util.feedkey("<esc>", "n")

  local method = "textDocument/rangeFormatting" ---@type string
  local resp = vim.lsp.buf_request_sync(0, method, para, timeoutms)

  apply_lsp_edit(resp)
end

lsp.v_range_format = function()
  local pos = YcVim.util.get_visual_selection()
  range_format(pos)
end

---@return YcVim.Lsp.Conf
local default_lsp_config = function()
  return {
    auto_format = false,
    keymaps = {
      [keys.lsp_goto_definition] = { lsp.method.definition },
      [keys.lsp_goto_references] = { lsp.method.references },
      [keys.lsp_format] = { lsp.method.format },
      [keys.lsp_impl] = { lsp.method.impl },
      [keys.lsp_code_action] = { lsp.method.code_action },

      [keys.lsp_goto_declaration] = { vim.lsp.buf.declaration },
      [keys.lsp_goto_type_definition] = { vim.lsp.buf.type_definition },
      [keys.lsp_hover] = { vim.lsp.buf.hover },
      [keys.lsp_rename] = { vim.lsp.buf.rename },
      [keys.lsp_range_format] = { function() end, "x" },
      [keys.lsp_err_goto_prev] = { vim.diagnostic.goto_prev },
      [keys.lsp_err_goto_next] = { vim.diagnostic.goto_next },

      [keys.lsp_signature_help] = {
        function()
          YcVim.cmp.hide()
          vim.lsp.buf.signature_help()
        end,
        "i",
      },

      [keys.lsp_toggle_inlay_hint] = {
        function()
          if vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
          end
        end,
      },
    },
  }
end

---@param user_lsp_config YcVim.Lsp.Conf|nil
---@return fun(client: vim.lsp.Client, bufnr: number)
lsp.on_attach_func = function(user_lsp_config)
  ---@param client vim.lsp.Client
  ---@param bufnr number
  return function(client, bufnr)
    -- 合并各个语言的不同配置
    local lsp_config = vim.tbl_deep_extend("force", default_lsp_config(), user_lsp_config or {}) ---@type YcVim.Lsp.Conf

    -- keymap
    local buf_map = function(mode, key, action)
      vim.keymap.set(mode, key, action, { noremap = true, buffer = bufnr, silent = true })
    end
    for key, action in pairs(lsp_config.keymaps) do
      if action ~= nil then
        local mode = action[2] or "n"
        buf_map(mode, key, action[1])
      end
    end

    vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
  end
end

return lsp
