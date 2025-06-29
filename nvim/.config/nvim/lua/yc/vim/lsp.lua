---@class YcVim.lsp
local lsp = {}

local keys = YcVim.keys
local env = YcVim.env

---@alias YcVim.Lsp.Action [function|string, string?]
---@alias YcVim.Lsp.Keymaps table<string, YcVim.Lsp.Action>

local v_range_format = function()
  local pos = YcVim.util.get_visual_selection()

  local startl = math.min(pos[1], pos[2])
  local endl = math.max(pos[1], pos[2])

  vim.lsp.buf.format {
    range = {
      ["start"] = { startl - 1, 0 },
      ["end"] = { endl - 1, 0 },
    },
  }

  YcVim.util.feedkey("<esc>", "n")
end

---@type table<string, YcVim.Lsp.Keymaps>
local keymaps = {
  protols = {
    [keys.lsp_format] = { function() end },
  },
  emmylua_ls = {
    [keys.lsp_format] = {
      function()
        YcVim.lsp.action.plugin_format()
      end,
    },
  },
  lua_ls = {
    [keys.lsp_format] = {
      function()
        YcVim.lsp.action.plugin_format()
      end,
    },
  },
  gopls = {},
  clangd = {
    [keys.lsp_format] = { function() end },
    [keys.lsp_range_format] = { v_range_format, "x" },
    [keys.switch_source_header] = { ":ClangdSwitchSourceHeader<cr>" },
  },
  pyright = {
    [keys.lsp_format] = {
      function()
        YcVim.lsp.action.plugin_format()
      end,
    },
  },
}

---@return YcVim.Lsp.Keymaps
local default_lsp_keymap = function()
  return {
    [keys.lsp_goto_definition] = { lsp.action.definition },
    [keys.lsp_goto_references] = { lsp.action.references },
    [keys.lsp_format] = { lsp.action.format },
    [keys.lsp_impl] = { lsp.action.impl },
    [keys.lsp_code_action] = { lsp.action.code_action },
    [keys.lsp_goto_declaration] = { vim.lsp.buf.declaration },
    [keys.lsp_goto_type_definition] = { vim.lsp.buf.type_definition },
    [keys.lsp_hover] = {
      function()
        vim.lsp.buf.hover {
          border = "rounded",
          max_height = math.floor(vim.o.lines * 0.9),
          max_width = math.floor(vim.o.columns * 0.5),
        }
      end,
    },
    [keys.lsp_rename] = { vim.lsp.buf.rename },
    [keys.lsp_range_format] = { function() end, "x" },
    [keys.lsp_err_goto_prev] = {
      function()
        vim.diagnostic.jump { count = -1, float = true }
      end,
    },
    [keys.lsp_err_goto_next] = {
      function()
        vim.diagnostic.jump { count = 1, float = true }
      end,
    },
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
  }
end

---@param name string
---@return lsp.ClientCapabilities
lsp.capabilities = function(name)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  ---@module 'blink.cmp'
  local blink = package.loaded["blink.cmp"]
  if blink then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  ---@module 'cmp_nvim_lsp'
  local cmp_nvim_lsp = package.loaded["cmp_nvim_lsp"]
  if cmp_nvim_lsp then
    capabilities = require("cmp_nvim_lsp").default_capabilities()
  end

  if name == "clangd" then
    capabilities.textDocument.completion.editsNearCursor = true
    capabilities.offsetEncoding = { "utf-8", "utf-16" }
  end

  return capabilities
end

lsp.action = {
  definition = vim.lsp.buf.definition,
  references = vim.lsp.buf.references,
  impl = vim.lsp.buf.implementation,
  code_action = vim.lsp.buf.code_action,
  format = function()
    vim.lsp.buf.format { async = false }
    vim.cmd "silent write"
  end,
  plugin_format = function()
    vim.notify "not support now"
  end, --插件格式化
}

---@param bufnr integer
---@param lsp_keymap YcVim.Lsp.Keymaps?
lsp.buf_map = function(bufnr, lsp_keymap)
  lsp_keymap = vim.tbl_deep_extend("force", default_lsp_keymap(), lsp_keymap or {})

  local buf_map = function(mode, key, action)
    vim.keymap.set(mode, key, action, { noremap = true, buffer = bufnr, silent = true })
  end

  for key, action in pairs(lsp_keymap) do
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
  },

  clangd = {
    cmd = {
      "clangd",
      "-j=15", -- TODO(yc)
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--pch-storage=memory",
      env.usePlaceholders and "--function-arg-placeholders=1" or "--function-arg-placeholders=0",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "hpp", "h" },
    commands = { Format = { lsp.action.format, description = "format" } },
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

    local keymap = keymaps[client.name]
    if keymap then
      lsp.buf_map(bufnr, keymap)
    end
  end,
})

vim.keymap.del("n", "grr")
vim.keymap.del("n", "grt")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "gra")
vim.keymap.del("x", "gra")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "]d")
vim.keymap.del("n", "[d")

return lsp
