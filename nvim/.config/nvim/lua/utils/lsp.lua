local M = {}

local keys = require "basic.keys"
local env = require("basic.env").env
local helper = require "utils.helper"
local api = vim.api

AUTO_FORMATTING_ENABLED = false
local toggle_auto_formatting = function()
  AUTO_FORMATTING_ENABLED = not AUTO_FORMATTING_ENABLED
  print(string.format("auto_formatting: %s", AUTO_FORMATTING_ENABLED))
end

local formatting_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

M.lsp_client_cbs = {}

M.register_lsp_client_cb = function(cb)
  table.insert(M.lsp_client_cbs, cb)
end

M.range_format = function(pos)
  local timeoutms = 1000
  -- local context = { source = { organizeImports = true } }
  -- vim.validate { context = { context, "t", true } }
  -- local para = vim.lsp.util.make_range_params()
  local para = vim.lsp.util.make_given_range_params()
  if pos ~= nil then
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
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
  end
  local method = "textDocument/rangeFormatting"
  local resp = vim.lsp.buf_request_sync(0, method, para, timeoutms)

  if resp and resp[1] then
    local result = resp[1].result
    if result then
      local uri = vim.uri_from_bufnr(0)
      local textDocument = { uri = uri, version = 0 }
      local edits = result
      local documentChanges = {}
      table.insert(documentChanges, { edits = edits, textDocument = textDocument })
      local change_list = { documentChanges = documentChanges }
      -- TODO how to get file encoding
      vim.lsp.util.apply_workspace_edit(change_list, "utf-8")
    end
  end
end

M.v_range_format = function()
  local pos = helper.get_visual_selection()
  require("utils.lsp").range_format(pos)
end

M.key_on_attach = function(conf)
  return function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local bmap = helper.build_keymap(opts)

    local lsp_config = {
      auto_format = false,
      -- auto_format_func custom define func
    }

    local kms = {
      [keys.lsp_goto_declaration] = { vim.lsp.buf.declaration, "n" },
      [keys.lsp_goto_definition] = { vim.lsp.buf.definition, "n" },
      [keys.lsp_goto_references] = { vim.lsp.buf.references, "n" },
      [keys.lsp_goto_type_definition] = { vim.lsp.buf.type_definition, "n" },
      [keys.lsp_hover] = { vim.lsp.buf.hover, "n" },
      [keys.lsp_impl] = { vim.lsp.buf.implementation, "n" },
      [keys.lsp_rename] = { vim.lsp.buf.rename, "n" },
      [keys.lsp_signature_help] = { vim.lsp.buf.signature_help, "i" },
      [keys.lsp_format] = { M.format, "n" },
      [keys.lsp_code_action] = { vim.lsp.buf.code_action, "n" },
      [keys.lsp_err_goto_prev] = { vim.diagnostic.goto_prev, "n" },
      [keys.lsp_err_goto_next] = { vim.diagnostic.goto_next, "n" },
      [keys.lsp_incoming_calls] = { vim.lsp.buf.incoming_calls, "n" },
    }

    if not env.semantic_token and vim.fn.has "nvim-0.9" == 1 then -- disable semantic
      client.server_capabilities.semanticTokensProvider = nil
    end

    if conf and conf.client_cb and type(conf.client_cb) == "function" then
      conf.client_cb(client, bufnr, kms, lsp_config)
    end

    for _, cb in ipairs(M.lsp_client_cbs) do
      cb(client, bufnr, kms)
    end

    if client.supports_method "textDocument/formatting" and lsp_config.auto_format then
      kms[keys.lsp_toggle_autoformat] = { toggle_auto_formatting, "n" }

      vim.api.nvim_clear_autocmds { group = formatting_augroup, buffer = bufnr }
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = formatting_augroup,
        buffer = bufnr,
        callback = function()
          if not AUTO_FORMATTING_ENABLED then
            return
          end

          if lsp_config.auto_format_func ~= nil then
            lsp_config.auto_format_func()
          else
            vim.lsp.buf.format()
          end
        end,
      })
    end

    for key, action in pairs(kms) do
      if action ~= nil then
        bmap(action[2], key, action[1])
      end
    end

    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
  end
end

function M.format()
  if vim.fn.has "nvim-0.8" == 1 then
    vim.lsp.buf.format { async = true }
  else
    vim.lsp.buf.formatting()
  end
end

function M.go_import()
  local timeoutms = 1000
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, "t", true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  local method = "textDocument/codeAction"
  local resp = vim.lsp.buf_request_sync(0, method, params, timeoutms)
  if resp and resp[1] then
    local result = resp[1].result
    if result and result[1] then
      local edit = result[1].edit
      vim.lsp.util.apply_workspace_edit(edit, "utf-8")
    end
  end
  M.format()
  print "import go and format done!!!"
end

function M.go_to_cpp() -- not used
  local cur = api.nvim_buf_get_name(0)
  local res = string.gsub(cur, ".h$", ".cpp")

  if res == cur then
    print(cur .. " is not a .h style file")
    return
  end

  local find_res = vim.fn.findfile(res)
  if find_res == "" then
    print "find_res not found"
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(res))
end

return M
