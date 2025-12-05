local env = YcVim.env

local servers = {}

--- @brief: go
if vim.fn.executable "gopls" == 1 then
  servers.gopls = {
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
  }
end

--- @brief: proto
if vim.fn.executable "protols" == 1 then
  servers.protols = {}
end

--- @brief: json
if vim.fn.executable "vscode-json-language-server" == 1 then
  servers.jsonls = {}
end

--- @brief: typescript/javascript
if vim.env.TS_LSPREFER_TSGO and vim.fn.executable "tsgo" == 1 then
  servers.tsgo = {}
elseif vim.fn.executable "vtsls" == 1 then
  servers.vtsls = {} -- npm install -g @vtsls/language-server
end

--- @brief: c/cpp
if vim.env.CPP_LS_PREFER_CCLS and vim.fn.executable "ccls" == 1 then
  servers.ccls = {}
elseif vim.fn.executable "clangd" == 1 then
  servers.clangd = {
    cmd = {
      "clangd",
      "-j=15", -- TODO(yc)
      "--completion-style=detailed",
      "--header-insertion=iwyu",
      "--pch-storage=memory",
      env.usePlaceholders and "--function-arg-placeholders=1" or "--function-arg-placeholders=0",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "hpp", "h" },
  }
end

--- @brief: lua
if vim.env.LUA_LS_PREFER_EMMYLUA and vim.fn.executable "emmylua_ls" == 1 then
  servers.emmylua_ls = {}
elseif vim.fn.executable "lua-language-server" == 1 then
  servers.lua_ls = {
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

--- @brief: python
if vim.fn.executable "ty" == 1 then
  servers.ty = {}
elseif vim.fn.executable "pyright" == 1 then
  servers.pyright = {
    filetypes = { "python" },
    settings = {
      python = {
        analysis = { autoSearchPaths = true, diagnosticMode = "workspace", useLibraryCodeForTypes = true },
      },
    },
    single_file_support = true,
  }
end

-- install lsp-server from
-- https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
return {
  "neovim/nvim-lspconfig",
  event = "User FilePost",
  config = function()
    for name, opt in pairs(servers) do
      vim.lsp.config(
        name,
        vim.tbl_deep_extend("error", opt, {
          on_init = function(client, _)
            if client.server_capabilities and not env.semantic_token then
              client.server_capabilities.semanticTokensProvider = false
            end
          end,
          capabilities = YcVim.lsp.capabilities(name),
        })
      )
      vim.lsp.enable(name)
    end
  end,
}
