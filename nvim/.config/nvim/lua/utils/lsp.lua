local keys = require "basic.keys"
local env = require("basic.env").env
local helper = require "utils.helper"
local api = vim.api

---@alias Yc.KeyMaps table<string, table>

---@class Yc.LspConf
---@field auto_format boolean
---@field keymaps Yc.KeyMaps

local function sync_format_save()
  vim.lsp.buf.format { async = false }
  vim.cmd "silent write"
end

local M = {
  lsp_method = {
    -- 默认方法, 后续会被插件覆盖（fzf-lua)
    definition = vim.lsp.buf.definition,
    references = vim.lsp.buf.references,
    impl = vim.lsp.buf.implementation,
    code_action = vim.lsp.buf.code_action,
    format = sync_format_save,
  },
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
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)

  local method = "textDocument/rangeFormatting" ---@type string
  local resp = vim.lsp.buf_request_sync(0, method, para, timeoutms)

  apply_lsp_edit(resp)
end

M.v_range_format = function()
  local pos = helper.get_visual_selection()
  range_format(pos)
end

---@return Yc.LspConf
local default_lsp_config = function()
  return {
    auto_format = false,
    keymaps = {
      [keys.lsp_goto_definition] = { M.lsp_method.definition },
      [keys.lsp_goto_references] = { M.lsp_method.references },
      [keys.lsp_format] = { M.lsp_method.format },
      [keys.lsp_impl] = { M.lsp_method.impl },
      [keys.lsp_code_action] = { M.lsp_method.code_action },

      [keys.lsp_goto_declaration] = { vim.lsp.buf.declaration },
      [keys.lsp_goto_type_definition] = { vim.lsp.buf.type_definition },
      [keys.lsp_hover] = { vim.lsp.buf.hover },
      [keys.lsp_rename] = { vim.lsp.buf.rename },
      [keys.lsp_range_format] = { function() end, "x" },
      [keys.lsp_err_goto_prev] = { vim.diagnostic.goto_prev },
      [keys.lsp_err_goto_next] = { vim.diagnostic.goto_next },

      [keys.lsp_signature_help] = {
        function()
          require("utils.cmp").hide()
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

local formatting_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local setup_auto_format = function(lsp_config, client, bufnr)
  if not client.supports_method "textDocument/formatting" then
    return
  end

  local toggle = function()
    vim.g.auto_formatting_enable = not vim.g.auto_formatting_enable
    print(string.format("auto_formatting: %s", vim.g.auto_formatting_enable))
  end

  lsp_config.keymaps[keys.lsp_toggle_autoformat] = { toggle }

  vim.api.nvim_clear_autocmds { group = formatting_augroup, buffer = bufnr }
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = formatting_augroup,
    buffer = bufnr,
    callback = function()
      if vim.g.auto_formatting_enable then
        vim.lsp.buf.format()
      end
    end,
  })
end

---@param user_lsp_config Yc.LspConf|nil
---@return fun(client: vim.lsp.Client, bufnr: number)
M.build_on_attach_func = function(user_lsp_config)
  ---@param client vim.lsp.Client
  ---@param bufnr number
  return function(client, bufnr)
    -- 合并各个语言的不同配置
    local lsp_config = vim.tbl_deep_extend("force", default_lsp_config(), user_lsp_config or {}) ---@type Yc.LspConf

    -- 格式化
    if lsp_config.auto_format then
      setup_auto_format(lsp_config, client, bufnr)
    end

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

return M
