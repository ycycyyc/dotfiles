local M = {}

local keys = require "basic.keys"
local helper = require "utils.helper"
local api = vim.api

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

M.key_on_attach = function(conf)
  return function(_, bufnr)
    local filetype = vim.api.nvim_buf_get_option(0, "filetype")
    local opts = { noremap = true, silent = true, buffer = bufnr }
    local map = helper.build_keymap(opts)

    map("n", keys.lsp_goto_declaration, vim.lsp.buf.declaration)
    map("n", keys.lsp_goto_definition, vim.lsp.buf.definition)
    map("n", keys.lsp_goto_references, vim.lsp.buf.references)
    map("n", keys.lsp_goto_type_definition, vim.lsp.buf.type_definition)
    if filetype ~= "lua" then
      map("n", keys.lsp_hover, vim.lsp.buf.hover)
    end
    map("n", keys.lsp_impl, vim.lsp.buf.implementation)
    map("n", keys.lsp_rename, vim.lsp.buf.rename)
    map("i", keys.lsp_signature_help, vim.lsp.buf.signature_help)

    if conf and conf.diable_format then
      map("v", keys.lsp_range_format_cpp, function()
        local pos = helper.get_visual_selection()
        M.range_format(pos)
      end)
    elseif filetype ~= "lua" then
      map("n", keys.lsp_format, M.format)
    end

    map("n", keys.lsp_code_action, vim.lsp.buf.code_action)
    if conf and conf.rust == true then
      if conf.rt then
        local rt = conf.rt
        map("n", keys.lsp_hover, rt.hover_actions.hover_actions)
        map("n", keys.lsp_code_action, rt.code_action_group.code_action_group)
      end
    end

    map("n", keys.lsp_err_goto_prev, vim.diagnostic.goto_prev)
    map("n", keys.lsp_err_goto_next, vim.diagnostic.goto_next)

    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- map("n", keys.lsp_workspace_symbol, vim.lsp.buf.workspace_symbol)
    -- map("n", "<leader>pa", vim.lsp.buf.add_workspace_folder)
    -- map("n", "<leader>pr", vim.lsp.buf.remove_workspace_folder)
    map("n", keys.lsp_incoming_calls, vim.lsp.buf.incoming_calls)
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
  -- local res = cur

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
