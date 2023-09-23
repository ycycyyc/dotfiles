-- install lsp-server from
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local key_on_attach = require("utils.lsp").key_on_attach
local on_init = require("utils.lsp").on_init
local go_import = require("utils.lsp").go_import
local sync_format_save = require("utils.lsp").sync_format_save
local env = require("basic.env").env
local keys = require "basic.keys"

local M = {}

-- conf key binding
--
M.load_lsp_config = function()
  -- 0. base cofig
  local lspconfig = require "lspconfig"
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  vim.lsp.set_log_level "OFF"
  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { underline = false })

  -- 1. lua
  USER = vim.fn.expand "$USER"

  ---@type string[]
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  lspconfig.lua_ls.setup {
    on_init = on_init,
    capabilities = capabilities,
    on_attach = key_on_attach {
      client_cb = function(_, _, kms)
        kms[keys.lsp_format] = {
          function()
            if vim.fn.executable "stylua" == 1 then
              vim.cmd "Format"
            end
          end,
          "n",
        }
      end,
    },
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Setup your lua path
          path = runtime_path,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false, -- THIS IS THE IMPORTANT LINE TO ADD
        },
        hint = {
          enable = env.inlayhint,
        },
      },
    },
  }

  -- 2. gopls
  lspconfig.gopls.setup {
    on_init = on_init,
    on_attach = key_on_attach {
      client_cb = function(_, _, kms, lsp_config)
        lsp_config.auto_format = true
        kms[keys.lsp_format] = {
          function()
            go_import()
            sync_format_save()
          end,
          "n",
        }
      end,
    },
    capabilities = capabilities,
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
    commands = {
      GoImportAndFormat = {
        function()
          require("utils.lsp").go_import()
          require("utils.lsp").sync_format_save()
        end,
      },
    },
    root_dir = function()
      return vim.fn.getcwd()
    end,
  }

  -- 3. clangd
  ---@param bufnr number
  ---@param splitcmd string
  local function switch_source_header_splitcmd(bufnr, splitcmd)
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
      vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(dst_file))
    end)
  end

  ---@type string
  local clangd_bin = env.clangd_bin

  lspconfig.clangd.setup {
    on_init = on_init,
    capabilities = capabilities,
    on_attach = key_on_attach {
      client_cb = function(_, _, kms)
        kms[keys.lsp_format] = { function() end, "n" }
        kms[keys.lsp_range_format] = { require("utils.lsp").v_range_format, "x" }
        kms[keys.switch_source_header] = {
          function()
            switch_source_header_splitcmd(0, "edit")
          end,
          "n",
        }
      end,
    },
    cmd = {
      clangd_bin,
      "--background-index",
      "--suggest-missing-includes", -- 在后台自动分析文件（基于complie_commands)
      -- "--background-index",
      -- 标记compelie_commands.json文件的目录位置
      -- 关于complie_commands.json如何生成可见我上一篇文章的末尾
      -- https://zhuanlan.zhihu.com/p/84876003
      -- "--compile-commands-dir=build",
      -- 同时开启的任务数量
      "-j=15", -- 告诉clangd用那个clang进行编译，路径参考which clang++的路径
      -- "--query-driver=/usr/bin/clang++",
      -- clang-tidy功能
      "--clang-tidy", -- "--clang-tidy-checks=performance-*,bugprone-*",
      -- "--clang-tidy-checks=*",
      -- 全局补全（会自动补充头文件）
      "--all-scopes-completion", -- 更详细的补全内容
      "--completion-style=detailed", -- 补充头文件的形式
      "--header-insertion=iwyu", -- pch优化的位置
      "--pch-storage=memory", -- "--query-driver=/data/opt/gcc-5.4.0/bin/g++",
      env.usePlaceholders and "--function-arg-placeholders" or "--function-arg-placeholders=0",
      -- "-Wuninitialized",
      -- '--query-driver="/usr/local/opt/gcc-arm-none-eabi-8-2019-q3-update/bin/arm-none-eabi-gcc"'
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "hpp", "h" },
    commands = {
      Format = {
        function()
          require("utils.lsp").format()
        end,
        description = "format",
      },
    },
  }

  -- 4. other python json yaml cmake ts bash vimls
  lspconfig.pyright.setup {
    on_init = on_init,
    capabilities = capabilities,
    filetypes = { "python" },
    on_attach = key_on_attach {
      client_cb = function(_, _, kms)
        kms[keys.lsp_format] = {
          function()
            if vim.fn.executable "black" == 1 then
              vim.cmd "Format"
            end
          end,
          "n",
        }
      end,
    },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
        },
      },
    },
    single_file_support = true,
  }

  -- json format :%!python -m json.tool
  lspconfig.jsonls.setup {
    on_init = on_init,
    on_attach = key_on_attach(),
    cmd = { "vscode-json-languageserver", "--stdio" },
    filetypes = { "json" },
  }

  lspconfig.yamlls.setup {
    on_init = on_init,
    on_attach = key_on_attach(),
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml" },
  }
  -- lspinstall cmake
  lspconfig.cmake.setup {
    -- YOUR_PATH
    cmd = { "/data/yc/.local/share/nvim/lspinstall/cmake/venv/bin/cmake-language-server" },
    on_init = on_init,
    on_attach = key_on_attach(),
    filetypes = { "cmake" },
  }

  lspconfig.tsserver.setup {
    on_init = on_init,
    on_attach = key_on_attach {
      client_cb = function(_, _, kms, lsp_config)
        lsp_config.auto_format = true
        kms[keys.lsp_range_format] = { require("utils.lsp").v_range_format, "x" }
      end,
    },
  }
  -- lspconfig.denols.setup {
  --   on_attach = key_on_attach(),
  -- }

  -- https://github.com/bash-lsp/bash-language-server
  lspconfig.bashls.setup {
    on_init = on_init,
    on_attach = key_on_attach(),
  }

  lspconfig.vimls.setup {
    on_attach = key_on_attach(),
    on_init = on_init,
  }
end

M.rust_config = function()
  -- lspconfig.rust_analyzer.setup({
  --     on_attach = key_on_attach(),
  --     settings = {
  --         ["rust-analyzer"] = {
  --             assist = {importGranularity = "module", importPrefix = "by_self"},
  --             cargo = {loadOutDirsFromCheck = true},
  --             procMacro = {enable = true}
  --         }
  --     }
  -- })
  local rt = require "rust-tools"
  rt.setup {
    server = {
      on_attach = key_on_attach {
        client_cb = function(_, _, kms)
          kms[keys.lsp_hover] = { rt.hover_actions.hover_actions, "n" }
          kms[keys.lsp_code_action] = { rt.code_action_group.code_action_group, "n" }
        end,
      },
    },
  }
end

return M
