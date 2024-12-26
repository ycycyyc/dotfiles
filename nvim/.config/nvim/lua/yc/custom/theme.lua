local colors = YcVim.colors

local theme = {
  --- 1. grammer
  Constant = { myfg = colors.cyan },
  Error = { myfg = colors.red },
  Identifier = { myfg = colors.red },
  String = { myfg = colors.green },

  PreProc = { myfg = colors.yellow },
  PreCondit = { myfg = colors.yellow },
  Type = { myfg = colors.yellow },
  Typedef = { myfg = colors.yellow },
  Structure = { myfg = colors.yellow },
  StorageClass = { myfg = colors.yellow },

  Number = { myfg = colors.dark_yellow },
  Character = { myfg = colors.dark_yellow },
  Boolean = { myfg = colors.dark_yellow },
  SpecialChar = { myfg = colors.dark_yellow },

  Comment = { myfg = colors.comment_grey },
  SpecialComment = { myfg = colors.comment_grey },

  Function = { myfg = colors.blue },
  Special = { myfg = colors.blue },
  Include = { myfg = colors.blue },

  Statement = { myfg = colors.purple },
  Conditional = { myfg = colors.purple },
  Repeat = { myfg = colors.purple },
  Label = { myfg = colors.purple },
  Operator = { myfg = colors.purple },
  Keyword = { myfg = colors.purple },
  Exception = { myfg = colors.purple },
  Define = { myfg = colors.purple },
  Macro = { myfg = colors.purple },
  Todo = { myfg = colors.purple },

  --- 2. builtin
  -- Cursor = { myfg = black, mybg = blue },
  Search = { myfg = colors.black, mybg = colors.yellow },
  IncSearch = { cterm = { reverse = true } },
  Directory = { myfg = colors.blue },
  Pmenu = { myfg = colors.white, mybg = colors.menu_grey },
  PmenuSel = { myfg = colors.cursor_grey1, mybg = colors.blue },
  PmenuSbar = { mybg = colors.cursor_grey1 },
  PmenuThumb = { mybg = colors.white },

  SignColumn = { mybg = colors.menu_grey },
  LineNr = { myfg = colors.comment_grey, mybg = colors.menu_grey },
  MatchParen = { myfg = colors.white, underline = true },
  CursorLineNr = { mybg = colors.menu_grey, myfg = colors.current_line, cterm = {} },

  diffAdded = { myfg = colors.green },
  diffRemoved = { myfg = colors.red },

  DiffAdd = { myfg = colors.black, mybg = colors.green },
  DiffDelete = { myfg = colors.black, mybg = colors.red },
  DiffText = { myfg = colors.black, mybg = colors.yellow },

  ColorColumn = { mybg = colors.cursor_grey1 },

  Visual = { mybg = colors.virtual_grey }, -- 0.10 version

  Title = { myfg = colors.red, cterm = { bold = true } },
  FloatTitle = { cterm = { bold = true }, myfg = colors.red },
  FloatBorder = { link = "clear" },

  DiagnosticInfo = { myfg = colors.blue },
  DiagnosticHint = { myfg = colors.blue },
  CmpItemAbbrMatch = { myfg = colors.yellow },

  -- tabline
  TabLineFill = { mybg = colors.menu_grey },
  TabLineSel = { mybg = colors.green, myfg = colors.black },
  TabLine = { mybg = colors.menu_grey, myfg = colors.white },

  -- c/cpp
  cStructure = { myfg = colors.purple },
  cBlock = { myfg = colors.white },
  cppStructure = { link = "Keyword" },
  cStorageClass = { link = "Keyword" },
  cppModifier = { link = "Keyword" },
  cppStorageClass = { link = "Keyword" },

  -- go
  goBlock = { link = "@variable" },

  -- js/ts
  typescriptTry = { link = "Keyword" },
  typescriptExceptions = { link = "Keyword" },
  typescriptTypeReference = { link = "Type" },
  typescriptVariable = { link = "Keyword" },
  typescriptOperator = { link = "Keyword" },
  typescriptImport = { link = "Keyword" },
  javaScriptFunction = { link = "Keyword" },

  MsgArea = { myfg = colors.white, mybg = colors.cmdline },

  -- " 0.10
  NormalFloat = { link = "Pmenu" },

  -- lsp
  LspDiagnosticsVirtualTextError = { myfg = colors.red },
  LspDiagnosticsVirtualTextWarning = { myfg = colors.yellow },
  LspProgress = { myfg = colors.yellow, cterm = { bold = true } },
  LspInlayHint = { ctermfg = 61, ctermbg = 234 },

  -- statusline
  StatusLine = { myfg = colors.cursor_grey1, mybg = colors.white },
  StatusLineNC = { myfg = colors.cursor_grey1, mybg = colors.cursor_grey1 },
  StatusLineNormal = { myfg = colors.white, mybg = colors.cursor_grey2 },
  StatusLineFunction = { myfg = colors.blue, mybg = colors.cursor_grey2, cterm = { bold = true } },
  StatusLineError = { myfg = colors.red, mybg = colors.cursor_grey2, cterm = { bold = true } },
  StatusLineWarnning = { myfg = colors.yellow, mybg = colors.cursor_grey2, cterm = { bold = true } },
  StatusLineCurFile = { myfg = colors.cmdline, mybg = colors.green, cterm = { bold = true } },
  StatusLineBufListNormal = { myfg = colors.white, mybg = colors.cursor_grey4, cterm = { bold = true } },
  StatusLineGitSigns = { myfg = colors.white, mybg = colors.cursor_grey5, cterm = { bold = true } },
  StatusLineGitInfos = { myfg = colors.white, mybg = colors.cursor_grey5, cterm = { bold = true } },
  StatusLineTotalLine = { myfg = colors.white, mybg = colors.cursor_grey5, cterm = { bold = true } },
  StatusLineOff = { myfg = colors.white, mybg = colors.cursor_grey5, cterm = { bold = true } },
  StatusLineWinnr = { myfg = colors.black, mybg = colors.yellow, cterm = { bold = true } },
  StatusLineGitHead = { myfg = colors.white, mybg = colors.cursor_grey4, cterm = { bold = true } },
  StatusLineNBuffers = { myfg = colors.black, mybg = colors.blue, cterm = { bold = true } },

  WinSeparator = { mybg = colors.cursor_grey2 },

  StatusNormalMode = { myfg = colors.black, mybg = colors.blue, cterm = { bold = true } },
  StatusInsertMode = { myfg = colors.black, mybg = colors.purple, cterm = { bold = true } },
  StatusTermMode = { myfg = colors.black, mybg = colors.yellow, cterm = { bold = true } },
  StatusVisMode = { myfg = colors.black, mybg = colors.dark_yellow, cterm = { bold = true } },
  StatusVlMode = { myfg = colors.black, mybg = colors.dark_yellow, cterm = { bold = true } },
  StatusSelMode = { myfg = colors.black, mybg = colors.cyan, cterm = { bold = true } },
  StatusCmdMode = { myfg = colors.black, mybg = colors.red, cterm = { bold = true } },

  ---- plugin
  -- nvim-tree
  NvimTreeCursorLine = { mybg = colors.menu_grey },
  NvimTreeRootFolder = { myfg = colors.yellow, cterm = { bold = true } },
  NvimTreeNormalFloat = { link = "clear" },

  -- coc
  CocPumSearch = { myfg = colors.yellow },
  CocTreeSelected = { mybg = colors.menu_grey },
  CocMenuSel = { link = "PmenuSel" },
  CocPum = { link = "Pmenu" },
  CocVirtualText = { link = "Comment" },
  CocInlayHint = { link = "LspInlayHint" },
  CocInlayHintType = { link = "LspInlayHint" },
  CocInlayHintParameter = { link = "LspInlayHint" },
  CocExplorerNormalFloat = { link = "clear" },
  CocExplorerNormalFloatBorder = { link = "clear" },
  CocErrorHighlight = { link = "clear" },
  CocWarningHighlight = { link = "clear" },
  CocInfoHighlight = { link = "clear" },
  CocHintHighlight = { link = "clear" },

  -- fzf-lua
  FzfLuaCursorLine = { mybg = colors.menu_grey },
  QuickFixLine = { mybg = colors.menu_grey },

  -- mini
  MiniFilesTitleFocused = { myfg = colors.yellow, cterm = { bold = true } },
  MiniFilesCursorLine = { mybg = colors.virtual_grey, cterm = { bold = true } },

  -- Neogit
  NeogitStatusHEAD = { myfg = colors.purple },
  NeogitMerging = { myfg = colors.yellow },
  NeogitBranch = { myfg = colors.green, cterm = { bold = true } },
  NeogitRemote = { myfg = colors.red },
  NeogitUntrackedfiles = { myfg = colors.purple },
  NeogitUnstagedchanges = { myfg = colors.purple },
  NeogitChangeUUunstaged = { myfg = colors.red },
  NeogitChangeModified = { myfg = colors.yellow },
  NeogitChangeDunstaged = { myfg = colors.red },
  NeogitRecentcommits = { myfg = colors.blue },
  NeogitChangeDeleted = { myfg = colors.red },
  NeogitChangeNstaged = { myfg = colors.purple },
  NeogitStagedchanges = { myfg = colors.blue, cterm = { bold = true } },
  NeogitBranchHead = { myfg = colors.blue },
  NeogitUnmergedchanges = { myfg = colors.yellow },
  NeogitPopupActionKey = { myfg = colors.red, cterm = { bold = true } },
  NeogitTagName = { myfg = colors.yellow, cterm = { bold = true } },
  NeogitChangeRstaged = { myfg = colors.red },
  NeogitUnpushedchanges = { myfg = colors.purple },

  -- grug
  GrugFarResultsPath = { link = "Keyword" },
  GrugFarResultsMatchRemoved = { link = "FindMatch" },
  GrugFarResultsMatch = { link = "FindMatch" },
  GrugFarResultsLineNo = { link = "DapUIThread" },
  GrugFarResultsMatchAdded = { ctermfg = 235, ctermbg = 204, cterm = { bold = true } },

  -- blink.cmp
  BlinkCmpGhostText = { link = "Comment" },

  -- dap
  DapUIStoppedThread = { myfg = colors.red },
  DapUIThread = { myfg = colors.green },
  DapUISource = { myfg = colors.blue },
  DapUIWatchesEmpty = { myfg = colors.blue },
  DapUILineNumber = { myfg = colors.yellow },
  DapUIScope = { myfg = colors.yellow },
  DapUIType = { myfg = colors.yellow },
  DapUIValue = { myfg = colors.green },
  DapUIBreakpointsPath = { myfg = colors.blue },

  -- flash.nvim
  FlashLabel = { cterm = { nocombine = true }, ctermfg = 0, ctermbg = 9 },

  -- gitsigns
  GitSignsAdd = { myfg = colors.green, mybg = colors.menu_grey },
  GitSignsChange = { myfg = colors.yellow, mybg = colors.menu_grey },
  GitSignsDelete = { myfg = colors.red, mybg = colors.menu_grey },

  -- aerial
  AerialNamespace = { myfg = colors.red, cterm = { bold = true } },
  AerialNamespaceIcon = { link = "AerialNamespace" },
  AerialMethod = { link = "Function" },
  AerialFunction = { link = "Function" },
  AerialStruct = { link = "Type" },
  AerialClass = { link = "Type" },
  AerialField = { myfg = colors.white },
  AerialFieldIcon = { myfg = colors.white },
  AerialConstructor = { link = "Type" },
  AerialConstructorIcon = { link = "AerialConstructor" },
  AerialEnum = { myfg = colors.cyan },

  -- snacks
  -- dashboard
  SnacksDashboardHeader = { myfg = colors.blue },

  --- 4. treesitter
  ["@variable"] = { myfg = colors.white },
  ["@parameter"] = { myfg = colors.white, bold = true },
  ["@punctuation.bracket"] = { myfg = colors.white },
  ["@punctuation.delimiter"] = { myfg = colors.white },
  ["@constant.builtin"] = { myfg = colors.dark_yellow },
  ["@type.qualifier"] = { myfg = colors.purple },
  ["@type.builtin"] = { myfg = colors.yellow },
  ["@storageclass.cpp"] = { myfg = colors.purple },
  ["@variable.builtin"] = { myfg = colors.red },
  ["@lsp.type.variable"] = { myfg = colors.white },
  ["@lsp.type.parameter"] = { myfg = colors.white, bold = true },
  ["@lsp.type.namespace"] = { myfg = colors.red },
  ["@lsp.type.namespace.cpp"] = { myfg = colors.red, bold = true },
  ["@lsp.type.macro.cpp"] = { myfg = colors.blue, bold = true },
  ["@lsp.typemod.variable.defaultLibrary"] = { myfg = colors.dark_yellow },
  ["@lsp.mod.readonly.go"] = { myfg = colors.cyan },
  ["@markup.raw.block.markdown"] = { link = "clear" },

  --- 5. custom define
  YcNameSpace = { myfg = colors.red },
  YcCppStructure = { myfg = colors.yellow },
  NumberBuffers = { myfg = colors.black, mybg = colors.blue, cterm = { bold = true } },
  FindMatch = { ctermfg = 235, ctermbg = 114, cterm = { bold = true } },
  MyFloatNormal = { link = "clear" },
  LazyNormal = { link = "clear" },
  SnippetTabstop = { link = "clear" },
}

for name, opt in pairs(theme) do
  local o = colors.convert(opt)
  vim.api.nvim_set_hl(0, name, o)
end
