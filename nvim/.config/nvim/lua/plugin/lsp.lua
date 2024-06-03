-- install lsp-server from
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local env = require("basic.env").env
local keys = require "basic.keys"
local ulsp = require "utils.lsp"

local M = {}

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

local conform_format = function()
  require("conform").format { bufnr = 0 }
end

local attach_confs = {
  lua_ls = {
    keymaps = {
      [keys.lsp_format] = { conform_format },
    },
  },
  gopls = {
    auto_format = true,
  },
  clangd = {
    keymaps = {
      [keys.lsp_format] = { function() end },
      [keys.lsp_range_format] = { ulsp.v_range_format, "x" },
      [keys.switch_source_header] = { switch_source_header_cmd },
    },
  },
  pyright = {
    keymaps = {
      [keys.lsp_format] = { conform_format },
    },
  },
}

local servers = {
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
    commands = { Format = { ulsp.lsp_method.format, description = "format" } },
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

M.config = function()
  local lspconfig = require "lspconfig"

  vim.lsp.set_log_level "OFF"
  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { underline = false })

  for name, opt in pairs(servers) do
    -- 1. 默认的配置
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local on_init = function(client, _)
      if client.server_capabilities and not env.semantic_token then
        client.server_capabilities.semanticTokensProvider = false
      end
    end

    local d_opt = {
      on_init = on_init,
      capabilities = capabilities,
    }

    -- 2. on_attach使用的配置
    local conf = attach_confs[name] or {}

    local a_opt = {
      on_attach = ulsp.build_on_attach_func(conf),
    }

    -- 3. 再加上每个lsp-server特有的配置
    lspconfig[name].setup(vim.tbl_deep_extend("error", opt, d_opt, a_opt))
  end
end

M.rust_config = function()
  local rt = require "rust-tools"
  rt.setup {
    server = {
      on_attach = ulsp.build_on_attach_func {
        keymaps = {
          [keys.lsp_hover] = { rt.hover_actions.hover_actions, "n" },
          [keys.lsp_code_action] = { rt.code_action_group.code_action_group, "n" },
        },
      },
    },
  }
end

return M
