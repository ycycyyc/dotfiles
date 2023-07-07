local M = {}

local hl = vim.api.nvim_set_hl
local env = require("basic.env").env

local function convert(opt)
  local res = {}

  for field, val in pairs(opt) do
    if field == "fg" then
      res.fg = val.gui
      res.ctermfg = val.n
    elseif field == "bg" then
      res.bg = val.gui
      res.ctermbg = val.n
    else
      res[field] = val
    end
  end

  return res
end

local function default_theme()
  -- lua vim.pretty_print(vim.treesitter.get_captures_at_cursor(0))
  local red = { n = 204, gui = "#ff5f87" }
  local blue = { n = 39, gui = "#00afff" }
  local black = { n = 235, gui = "#262626" }
  local dark_yellow = { n = 173, gui = "#d7875f" }
  local yellow = { n = 180, gui = "#d7af87" }
  local comment_grey = { n = 59, gui = "#5f5f5f" }
  local menu_grey = { n = 237, gui = "#3a3a3a" }
  local menu_grey2 = { n = 233, gui = "#121212" }
  local green = { n = 114, gui = "#87d787" }
  local white = { n = 145, gui = "#afafaf" }
  local cyan = { n = 38, gui = "#00afd7" }
  local purple = { n = 170, gui = "#d75fd7" }
  local cursor_grey = { n = 236, gui = "#303030" }
  local cmdlinebg = { n = 235, gui = "#303030" }
  local curent_line = { n = 11, gui = "#ffff00" }

  local colors = {
    Constant = { fg = cyan },
    Error = { fg = red },
    Identifier = { fg = red },
    String = { fg = green },

    PreProc = { fg = yellow },
    PreCondit = { fg = yellow },
    Type = { fg = yellow },
    Typedef = { fg = yellow },
    Structure = { fg = yellow },
    StorageClass = { fg = yellow },

    Number = { fg = dark_yellow },
    Character = { fg = dark_yellow },
    Boolean = { fg = dark_yellow },
    SpecialChar = { fg = dark_yellow },

    Comment = { fg = comment_grey },
    SpecialComment = { fg = comment_grey },

    Function = { fg = blue },
    Special = { fg = blue },
    Include = { fg = blue },

    Statement = { fg = purple },
    Conditional = { fg = purple },
    Repeat = { fg = purple },
    Label = { fg = purple },
    Operator = { fg = purple },
    Keyword = { fg = purple },
    Exception = { fg = purple },
    Define = { fg = purple },
    Macro = { fg = purple },
    Todo = { fg = purple },
    --
    Cursor = { fg = black, bg = blue },
    Search = { fg = black, bg = yellow },
    Directory = { fg = blue },

    Pmenu = { fg = white, bg = menu_grey },
    PmenuSel = { fg = cursor_grey, bg = blue },
    PmenuSbar = { bg = cursor_grey },
    PmenuThumb = { bg = white },

    GitSignsAdd = { fg = green, bg = menu_grey },
    GitSignsChange = { fg = yellow, bg = menu_grey },
    GitSignsDelete = { fg = red, bg = menu_grey },

    SignColumn = { bg = menu_grey },
    LineNr = { fg = comment_grey, bg = menu_grey },
    MatchParen = { fg = white, underline = true },
    CursorLineNr = { bg = menu_grey, fg = curent_line, cterm = {} },

    StatusLineNC = { bg = white },
    diffAdded = { fg = green },
    diffRemoved = { fg = red },

    DiffAdd = { fg = black, bg = green },
    DiffDelete = { fg = black, bg = red },
    DiffText = { fg = black, bg = yellow },

    ColorColumn = { bg = cursor_grey },

    DiagnosticInfo = { fg = blue },
    DiagnosticHint = { fg = blue },
    CmpItemAbbrMatch = { fg = yellow },

    -- tabline
    TabLineFill = { bg = menu_grey },
    TabLineSel = { bg = green, fg = black },
    TabLine = { bg = menu_grey, fg = white },

    NvimTreeCursorLine = { bg = menu_grey },

    cStructure = { fg = purple },
    cBlock = { fg = white },

    -- self define
    YcNameSpace = { fg = red },
    YcCppStructure = { fg = yellow },

    LspInlayHint = { fg = comment_grey, bg = cursor_grey },

    MsgArea = { fg = white, bg = cmdlinebg },
  }

  -- treesitter
  colors["@variable"] = { fg = white }
  colors["@parameter"] = { fg = white, bold = true }
  colors["@punctuation.bracket"] = { fg = white }
  colors["@punctuation.delimiter"] = { fg = white }
  colors["@constant.builtin"] = { fg = dark_yellow }
  colors["@type.qualifier"] = { fg = purple }
  colors["@storageclass.cpp"] = { fg = purple }
  colors["@variable.builtin.lua"] = { fg = red }

  if env.semantic_token == true then
    colors["@lsp.type.variable"] = { fg = white }
    colors["@lsp.type.parameter"] = { fg = white, bold = true }
    colors["@lsp.type.namespace"] = { fg = red }
    colors["@lsp.type.namespace.cpp"] = { fg = red, bold = true }
    colors["@lsp.type.macro.cpp"] = { fg = blue }
    colors["@lsp.typemod.variable.defaultLibrary"] = { fg = dark_yellow }
    colors["@lsp.mod.readonly.go"] = { fg = cyan }
  end

  -- cpp
  hl(0, "cppStructure", { link = "Keyword" })
  hl(0, "cStorageClass", { link = "Keyword" })
  hl(0, "cppModifier", { link = "Keyword" })
  hl(0, "cppStorageClass", { link = "Keyword" })
  -- go
  hl(0, "goBlock", { link = "@variable" })
  -- ts
  hl(0, "typescriptTry", { link = "Keyword" })
  hl(0, "typescriptExceptions", { link = "Keyword" })
  hl(0, "typescriptTypeReference", { link = "Type" })
  hl(0, "typescriptVariable", { link = "Keyword" })
  hl(0, "typescriptOperator", { link = "Keyword" })
  hl(0, "typescriptImport", { link = "Keyword" })

  -- remove statusline
  hl(0, "StatusLine", { link = "Normal" })
  hl(0, "StatusLineNC", { link = "Normal" })

  for name, opt in pairs(colors) do
    local o = convert(opt)
    hl(0, name, o)
  end
end

local function other_theme()
  vim.opt.termguicolors = true
  vim.g.base16colorspace = 256
  -- hl(0, "@variable", { fg = "white", bg = "NONE" })
end

local function onedark_theme()
  hl(0, "@variable", { fg = "white", bg = "NONE" })
end

function M.setup()
  local theme = env.theme

  if theme == "default" then
    default_theme()
  elseif theme == "onedark" then
    -- deprecated
    onedark_theme()
    -- deprecated
    vim.cmd("colorscheme " .. theme)
  else
    other_theme()
    vim.cmd("colorscheme " .. theme)
  end

  hl(0, "LspDiagnosticsVirtualTextError", { fg = "Red" })
  hl(0, "LspDiagnosticsVirtualTextWarning", { fg = "Yellow" })
end

return M
