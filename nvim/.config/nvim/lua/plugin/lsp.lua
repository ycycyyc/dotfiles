-- install lsp-server from
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local env = YcVim.env
local keys = YcVim.keys

local plugin = {}

local lua_ls_runtime_path = function()
  ---@type string[]
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")
  return runtime_path
end

local function switch_source_header_cmd()
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

local attach_confs = {
  protols = {
    keymaps = {
      [keys.lsp_format] = { function() end },
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
  gopls = {
    auto_format = true,
  },
  clangd = {
    keymaps = {
      [keys.lsp_format] = { function() end },
      [keys.lsp_range_format] = { YcVim.lsp.v_range_format, "x" },
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

local servers = {
  vtsls = {}, -- npm install -g @vtsls/language-server
  protols = {},
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = "LuaJIT", path = lua_ls_runtime_path() },
        diagnostics = { globals = { "vim" } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false, -- THIS IS THE IMPORTANT LINE TO ADD
        },
        hint = { enable = env.inlayhint },
      },
    },
  },

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
        staticcheck = true,
      },
    },
    root_dir = function()
      return vim.fn.getcwd()
    end,
  },

  clangd = {
    cmd = {
      env.clangd_bin,
      "--background-index",
      "--suggest-missing-includes",
      "-j=15",
      "--clang-tidy",
      "--all-scopes-completion",
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--pch-storage=memory",
      env.usePlaceholders and "--function-arg-placeholders" or "--function-arg-placeholders=0",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "hpp", "h" },
    commands = { Format = { YcVim.lsp.method.format, description = "format" } },
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

plugin.config = function()
  local lspconfig = require "lspconfig"

  vim.lsp.set_log_level "OFF"

  for name, opt in pairs(servers) do
    -- 1. 默认的配置
    local capabilities = YcVim.lsp.lsp_capabilities()

    local on_init = function(client, _)
      if client.server_capabilities and not env.semantic_token then
        client.server_capabilities.semanticTokensProvider = false
      end
    end

    local init_opt = {
      on_init = on_init,
      capabilities = capabilities,
    }

    -- 2. on_attach使用的配置
    local conf = attach_confs[name] or {}

    local attach_opt = {
      on_attach = YcVim.lsp.on_attach_func(conf),
    }

    -- 3. 再加上每个lsp-server特有的配置
    lspconfig[name].setup(vim.tbl_deep_extend("error", opt, init_opt, attach_opt))
  end

  -- 4. vim.diagnostics
  vim.diagnostic.config {
    underline = false,
    signs = false,
  }
end

return {
  "neovim/nvim-lspconfig",
  event = "User FilePost",
  config = plugin.config,
}
