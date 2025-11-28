local env = YcVim.env

local servers = {
  vtsls = {}, -- npm install -g @vtsls/language-server
  protols = {},
  jsonls = {},
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

if 1 == vim.fn.executable "jdtls" then
  servers.jdtls = { root_markers = { ".classpath" } }
end

if vim.env.EMMY and vim.fn.executable "emmylua_ls" == 1 then
  servers.emmylua_ls = {}
else
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
