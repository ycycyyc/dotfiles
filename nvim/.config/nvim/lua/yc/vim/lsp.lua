---@class YcVim.lsp
local lsp = {}

local keys = YcVim.keys
local env = YcVim.env

---@alias YcVim.Keymaps table<string, table>

---@class YcVim.Lsp.Conf
---@field keymaps? YcVim.Keymaps

local v_range_format = function()
  local pos = YcVim.util.get_visual_selection()

  local startp, endp = pos[1], pos[2]
  if startp > endp then
    startp, endp = pos[2], pos[1]
  end

  local range = {}
  range["start"] = { startp - 1, 0 }
  range["end"] = { endp - 1, 0 }

  vim.lsp.buf.format { range = range }
  YcVim.util.feedkey("<esc>", "n")
end

local switch_source_header_cmd = function()
  local bufnr = 0
  local cmd = "edit"
  local lspconfig = require "lspconfig"
  bufnr = lspconfig.util.validate_bufnr(bufnr)
  local params = { uri = vim.uri_from_bufnr(bufnr) }
  vim.lsp.buf_request(bufnr, "textDocument/switchSourceHeader", params, function(err, dst_file, result)
    if err then
      error(tostring(err))
    end
    if not result then
      print "Corresponding file can’t be determined"
      return
    end
    vim.api.nvim_command(cmd .. " " .. vim.uri_to_fname(dst_file))
  end)
end

local sync_format_save = function()
  vim.lsp.buf.format { async = false }
  vim.cmd "silent write"
end

---@type table<string, YcVim.Lsp.Conf>
local lsp_confs = {
  protols = {
    keymaps = {
      [keys.lsp_format] = { function() end },
    },
  },
  emmylua_ls = {
    keymaps = {
      [keys.lsp_format] = {
        function()
          YcVim.lsp.method.plugin_format()
        end,
      },
    },
  },
  lua_ls = {
    keymaps = {
      [keys.lsp_format] = {
        function()
          YcVim.lsp.method.plugin_format()
        end,
      },
    },
  },
  gopls = {},
  clangd = {
    keymaps = {
      [keys.lsp_format] = { function() end },
      [keys.lsp_range_format] = { v_range_format, "x" },
      [keys.switch_source_header] = { switch_source_header_cmd },
    },
  },
  pyright = {
    keymaps = {
      [keys.lsp_format] = {
        function()
          YcVim.lsp.method.plugin_format()
        end,
      },
    },
  },
}

local goto_prev_diagnostic = function()
  vim.diagnostic.jump { count = -1, float = true }
end

local goto_next_diagnostic = function()
  vim.diagnostic.jump { count = 1, float = true }
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
      [keys.lsp_hover] = {
        function()
          -- better hover
          vim.lsp.buf.hover {
            border = "rounded",
            max_height = math.floor(vim.o.lines * 0.9),
            max_width = math.floor(vim.o.columns * 0.5),
          }
        end,
      },
      [keys.lsp_rename] = { vim.lsp.buf.rename },
      [keys.lsp_range_format] = { function() end, "x" },
      [keys.lsp_err_goto_prev] = { goto_prev_diagnostic },
      [keys.lsp_err_goto_next] = { goto_next_diagnostic },

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

---@return lsp.ClientCapabilities
lsp.capabilities = function()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then
    return blink.get_lsp_capabilities(capabilities)
  end

  ---@module 'cmp_nvim_lsp'
  local cmp_nvim_lsp = package.loaded["cmp_nvim_lsp"]
  if cmp_nvim_lsp then
    return require("cmp_nvim_lsp").default_capabilities()
  end

  return capabilities
end

lsp.method = {
  definition = vim.lsp.buf.definition,
  references = vim.lsp.buf.references,
  impl = vim.lsp.buf.implementation,
  code_action = vim.lsp.buf.code_action,
  format = sync_format_save,
  plugin_format = function()
    vim.notify "not support now"
  end, --插件格式化
}

---@param lsp_conf YcVim.Lsp.Conf?
---@param _ vim.lsp.Client
---@param bufnr number
lsp.on_attach = function(lsp_conf, _, bufnr)
  lsp_conf = vim.tbl_deep_extend("force", default_lsp_config(), lsp_conf or {})

  local buf_map = function(mode, key, action)
    vim.keymap.set(mode, key, action, { noremap = true, buffer = bufnr, silent = true })
  end
  for key, action in pairs(lsp_conf.keymaps) do
    if action ~= nil then
      local mode = action[2] or "n"
      buf_map(mode, key, action[1])
    end
  end

  vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
end

lsp.servers = {
  vtsls = {}, -- npm install -g @vtsls/language-server
  protols = {},
  gopls = {
    cmd = { "gopls", "serve" },
    settings = {
      gopls = {
        semanticTokens = env.semantic_token,
        experimentalPostfixCompletions = true,
        usePlaceholders = env.usePlaceholders,
        analyses = {
          unusedparams = true,
          shadow = true,
          nilness = true,
          printf = true,
          unusedwrite = true,
          fieldalignment = false,
        },
        hints = {
          assignVariableTypes = env.inlayhint,
          compositeLiteralFields = env.inlayhint,
          compositeLiteralTypes = env.inlayhint,
          constantValues = env.inlayhint,
          functionTypeParameters = env.inlayhint,
          parameterNames = env.inlayhint,
          rangeVariableTypes = env.inlayhint,
        },
        -- staticcheck = true, -- go1.18不支持 gopls 0.14.2
      },
    },
    root_dir = function()
      return vim.fn.getcwd()
    end,
  },

  clangd = {
    cmd = {
      env.clangd_bin,
      "-j=15", -- TODO(yc)
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--pch-storage=memory",
      env.usePlaceholders and "--function-arg-placeholders=1" or "--function-arg-placeholders=0",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "hpp", "h" },
    commands = { Format = { lsp.method.format, description = "format" } },
  },

  pyright = {
    filetypes = { "python" },
    settings = {
      python = {
        analysis = { autoSearchPaths = true, diagnosticMode = "workspace", useLibraryCodeForTypes = true },
      },
    },
    single_file_support = true,
  },
}

if vim.env.EMMY and vim.fn.executable "emmylua_ls" == 1 then
  lsp.servers.emmylua_ls = {}
else
  lsp.servers.lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME, vim.env.VIMRUNTIME .. "/lua" },
        },
      },
    },
  }
end

-- vim.lsp.set_log_level "OFF"
vim.diagnostic.config {
  underline = false,
  signs = false,
  virtual_text = true,
}

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

    local lsp_conf = lsp_confs[client.name]
    if lsp_conf then
      lsp.on_attach(lsp_conf, client, bufnr)
    end
  end,
})

vim.keymap.del("n", "grr")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "gra")
vim.keymap.del("x", "gra")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "]d")
vim.keymap.del("n", "[d")

return lsp
