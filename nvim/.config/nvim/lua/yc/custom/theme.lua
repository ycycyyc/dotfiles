local hl = vim.api.nvim_set_hl

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
local cursor_grey2 = { n = 237, gui = "#303030" }
local cursor_grey4 = { n = 239, gui = "#303030" }
local cursor_grey5 = { n = 240, gui = "#303030" }
local virtual_grey = { n = 242, gui = "#303030" }
local cmdlinebg = { n = 235, gui = "#303030" }
local current_line = { n = 11, gui = "#ffff00" }

local M = {
  red = red,
  blud = blue,
  black = black,
  dark_yellow = dark_yellow,
  yellow = yellow,
  comment_grey = comment_grey,
  menu_grey = menu_grey,
  menu_grey2 = menu_grey2,
  green = green,
  white = white,
  cyan = cyan,
  purle = purple,
  cursor_grey = cursor_grey,
  cmdlinebg = cmdlinebg,
  current_line = current_line,

  started = false,
}

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
  -- Cursor = { fg = black, bg = blue },
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
  CursorLineNr = { bg = menu_grey, fg = current_line, cterm = {} },

  diffAdded = { fg = green },
  diffRemoved = { fg = red },

  DiffAdd = { fg = black, bg = green },
  DiffDelete = { fg = black, bg = red },
  DiffText = { fg = black, bg = yellow },

  ColorColumn = { bg = cursor_grey },

  Visual = { bg = virtual_grey }, -- 0.10 version

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

  MsgArea = { fg = white, bg = cmdlinebg },

  --dap
  DapUIStoppedThread = { fg = red },
  DapUIThread = { fg = green },
  DapUISource = { fg = blue },
  DapUIWatchesEmpty = { fg = blue },
  DapUILineNumber = { fg = yellow },
  DapUIScope = { fg = yellow },
  DapUIType = { fg = yellow },
  DapUIValue = { fg = green },
  DapUIBreakpointsPath = { fg = blue },

  -- lsp
  LspDiagnosticsVirtualTextError = { fg = red },
  LspDiagnosticsVirtualTextWarning = { fg = yellow },
  LspProgress = { fg = yellow, cterm = { bold = true } },

  -- statusline
  StatusLine = { fg = cursor_grey, bg = white },
  StatusLineNC = { fg = cursor_grey, bg = cursor_grey },
  StatusLineNormal = { fg = white, bg = cursor_grey2 },
  StatusLineFunction = { fg = blue, bg = cursor_grey2, cterm = { bold = true } },
  StatusLineError = { fg = red, bg = cursor_grey2, cterm = { bold = true } },
  StatusLineWarnning = { fg = yellow, bg = cursor_grey2, cterm = { bold = true } },
  StatusLineCurFile = { fg = cmdlinebg, bg = green, cterm = { bold = true } },
  StatusLineBufListNormal = { fg = white, bg = cursor_grey4, cterm = { bold = true } },
  StatusLineGitSigns = { fg = white, bg = cursor_grey5, cterm = { bold = true } },
  StatusLineTotalLine = { fg = white, bg = cursor_grey5, cterm = { bold = true } },
  StatusLineWinnr = { fg = black, bg = yellow, cterm = { bold = true } },
  NumberBuffers = { fg = black, bg = blue, cterm = { bold = true } },
  WinSeparator = { bg = cursor_grey2 },

  StatusNormalMode = { fg = black, bg = blue, cterm = { bold = true } },
  StatusInsertMode = { fg = black, bg = purple, cterm = { bold = true } },
  StatusTermMode = { fg = black, bg = yellow, cterm = { bold = true } },
  StatusVisMode = { fg = black, bg = dark_yellow, cterm = { bold = true } },
  StatusVlMode = { fg = black, bg = dark_yellow, cterm = { bold = true } },
  StatusSelMode = { fg = black, bg = cyan, cterm = { bold = true } },
  StatusCmdMode = { fg = black, bg = red, cterm = { bold = true } },

  --nvimtree
  NvimTreeSymlink = { fg = blue, cterm = { bold = true, underline = true } },

  -- Telescope
  TelescopeResultsTitle = { fg = red, cterm = { bold = true } },
  TelescopePreviewTitle = { fg = yellow, cterm = { bold = true } },
  TelescopePromptTitle = { fg = blue, cterm = { bold = true } },
  TelescopeMultiSelection = { fg = cyan },

  -- coc
  CocPumSearch = { fg = yellow },
  CocTreeSelected = { bg = menu_grey },

  -- fzf-lua
  FzfLuaCursorLine = { bg = menu_grey },
  QuickFixLine = { bg = menu_grey },

  -- mini
  MiniFilesTitleFocused = { fg = yellow, cterm = { bold = true } },
  MiniFilesCursorLine = { bg = virtual_grey, cterm = { bold = true } },

  -- Neogit
  NeogitStatusHEAD = { fg = purple },
  NeogitMerging = { fg = yellow },
  NeogitBranch = { fg = green, cterm = { bold = true } },
  NeogitRemote = { fg = red },
  NeogitUntrackedfiles = { fg = purple },
  NeogitUnstagedchanges = { fg = purple },
  NeogitChangeUUunstaged = { fg = red },
  NeogitChangeModified = { fg = yellow },
  NeogitChangeDunstaged = { fg = red },
  NeogitRecentcommits = { fg = blue },
  NeogitChangeDeleted = { fg = red },
  NeogitChangeNstaged = { fg = purple },
  NeogitStagedchanges = { fg = blue, cterm = { bold = true } },
  NeogitBranchHead = { fg = blue },
  NeogitUnmergedchanges = { fg = yellow },
  NeogitPopupActionKey = { fg = red, cterm = { bold = true } },
  NeogitTagName = { fg = yellow, cterm = { bold = true } },
  NeogitChangeRstaged = { fg = red },
  NeogitUnpushedchanges = { fg = purple },
}

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
  -- treesitter
  colors["@variable"] = { fg = white }
  colors["@parameter"] = { fg = white, bold = true }
  colors["@punctuation.bracket"] = { fg = white }
  colors["@punctuation.delimiter"] = { fg = white }
  colors["@constant.builtin"] = { fg = dark_yellow }
  colors["@type.qualifier"] = { fg = purple }
  colors["@type.builtin"] = { fg = yellow }
  colors["@storageclass.cpp"] = { fg = purple }
  colors["@variable.builtin"] = { fg = red }

  colors["@lsp.type.variable"] = { fg = white }
  colors["@lsp.type.parameter"] = { fg = white, bold = true }
  colors["@lsp.type.namespace"] = { fg = red }
  colors["@lsp.type.namespace.cpp"] = { fg = red, bold = true }
  colors["@lsp.type.macro.cpp"] = { fg = blue, bold = true }
  colors["@lsp.typemod.variable.defaultLibrary"] = { fg = dark_yellow }
  colors["@lsp.mod.readonly.go"] = { fg = cyan }

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

  hl(0, "CocMenuSel", { link = "PmenuSel" })
  hl(0, "CocPum", { link = "Pmenu" })
  hl(0, "CocVirtualText", { link = "Comment" })

  hl(0, "LspInlayHint", { ctermfg = 61, ctermbg = 234 })
  hl(0, "CocInlayHint", { link = "LspInlayHint" })
  hl(0, "CocInlayHintType", { link = "LspInlayHint" })
  hl(0, "CocInlayHintParameter", { link = "LspInlayHint" })

  -- " 0.10
  hl(0, "NormalFloat", { link = "Pmenu" })
  hl(0, "IncSearch", { cterm = { reverse = true } })
  hl(0, "FlashLabel", { cterm = { nocombine = true }, ctermfg = 0, ctermbg = 9 })

  hl(0, "LazyNormal", { link = "clear" })
  hl(0, "SnippetTabstop", { link = "clear" })

  for name, opt in pairs(colors) do
    local o = convert(opt)
    hl(0, name, o)
  end
end

function M.add(color)
  if M.started == false then
    table.insert(colors, color)
  else
    for name, opt in pairs(color) do
      local o = convert(opt)
      hl(0, name, o)
    end
  end
end

function M.setup()
  default_theme()
  M.started = true
end

return M
