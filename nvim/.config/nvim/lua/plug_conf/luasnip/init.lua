local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require "luasnip.util.events"
local ai = require "luasnip.nodes.absolute_indexer"
local extras = require "luasnip.extras"
local rep = require("luasnip.extras").rep

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local m = extras.m
local l = extras.l
local postfix = require("luasnip.extras.postfix").postfix
local conds = require "luasnip.extras.conditions"
local conds_expand = require "luasnip.extras.conditions.expand"

vim.keymap.set({ "i", "s" }, "<c-j>", function()
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
  require("luasnip").jump(-1)
end, { silent = true })

vim.cmd [[
  imap <silent><expr> <C-D> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-D>'
  smap <silent><expr> <C-D> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-D>'
]]

local contains_n_word = function(n)
  return function(line_to_cursor)
    local text = vim.fn.split(line_to_cursor, " ")
    text = vim.tbl_filter(function(el)
      return el ~= ""
    end, text)
    return #text == n
  end
end

local go_snippets = {
  s("json", { t '`json:"', i(0, "text"), t '"`' }),
  s("bson", { t '`bson:"', i(0, "text"), t '"`' }),
  s("yaml", { t '`yaml:"', i(0, "text"), t '"`' }),
  s("wg", { t "wg sync.WaitGroup" }, {
    show_condition = function(line_to_cursor)
      return vim.fn.matchstr(line_to_cursor, "var") ~= ""
    end,
  }),
  s("wg", { t "wg.Done()" }, {
    show_condition = function(line_to_cursor)
      return vim.fn.matchstr(line_to_cursor, "defer ") ~= ""
    end,
  }),
  s("infof", { t 'Infof("', i(1, "msg"), t ':%v", ', i(2, "val"), t ")" }, {
    show_condition = function(line_to_cursor)
      return vim.fn.matchstr(line_to_cursor, "log.") ~= ""
    end,
  }),
  s("debugf", { t 'Debugf("', i(1, "msg"), t ':%v", ', i(2, "val"), t ")" }, {
    show_condition = function(line_to_cursor)
      return vim.fn.matchstr(line_to_cursor, "log.") ~= ""
    end,
  }),
  s("errorf", { t 'Errorf("', i(1, "msg"), t ' :%v", ', i(2, "err"), t ")" }, {
    show_condition = function(line_to_cursor)
      return vim.fn.matchstr(line_to_cursor, "fmt.") ~= "" or vim.fn.matchstr(line_to_cursor, "log.") ~= ""
    end,
  }),
  s("sprintf", { t 'Sprintf("', i(1, "msg"), t ' %v", ', i(2, "msg"), t ")" }, {
    show_condition = function(line_to_cursor)
      return vim.fn.matchstr(line_to_cursor, "fmt.") ~= ""
    end,
  }),
  s("map", { t "map[", i(1, "type"), t "]", i(0) }),
  s("pkgm", fmt("package main\n\nfunc main() {{\n\t {} \n}}", { i(0) }), {
    -- show_condition = function(line)
    --   return line:len() <= 4
    -- end,
  }),
  s("chan", fmt("chan {}", { i(0, "type") })),
  s("switch", fmt("switch {} {}\ncase {}:\n\t{}\n{}", { i(1, "exp"), t "{", i(2, "cond"), i(0), t "}" })),
  s("case", fmt("case {}:\n\t{}", { i(1, "cond"), i(0) })),
  s(
    "typestruct",
    fmt(
      [[
      type <> struct {
          <>
      }
      ]],
      { i(1, "name"), i(0) },
      { delimiters = "<>" }
    )
  ),
  s(
    "typeinterface",
    fmt(
      [[
      type <> interface {
          <>
      }
      ]],
      { i(1, "name"), i(0) },
      { delimiters = "<>" }
    )
  ),
  s("typefunc", fmt([[ type <> func(<>) <> ]], { i(1, "name"), i(2), i(0) }, { delimiters = "<>" })),
  s(
    "select",
    fmt(
      [[
      select {
      case <>:
          <>
      default:
          <>
      }
      ]],
      { i(1, "cond"), i(2), i(0) },
      { delimiters = "<>" }
    )
  ),
  s(
    "forloop",
    fmt(
      [[
      for <> {
          <>
      }
      ]],
      { i(1, "cond"), i(0) },
      { delimiters = "<>" }
    )
  ),
  s(
    "fori",
    fmt(
      [[
      for <> := <>; <> <> <>; <><> {
          <>
      }
      ]],
      {
        i(1, "i"),
        i(2, "0"),
        rep(1),
        t "<",
        i(3, "count"),
        rep(1),
        i(4, "++"),
        i(5),
      },
      { delimiters = "<>" }
    )
  ),
  s(
    "err",
    fmt(
      [[
      <> != nil {
          return <><>
      }
      ]],
      { i(1, "err"), c(2, { i(nil, "nil, "), t "" }), rep(1) },
      {
        delimiters = "<>",
        show_condition = function(line_to_cursor)
          return vim.fn.matchstr(line_to_cursor, "if") ~= ""
        end,
      }
    )
  ),
}

ls.add_snippets("go", go_snippets)

local lua_snippets = {
  s("require", fmt([[ require("<>") ]], { i(1, "name") }, { delimiters = "<>" })),
  s("keymap", fmt([[ vim.keymap.set(<>, <>, <>)]], { i(1, '"n"'), i(2, "action"), i(3, "{}") }, { delimiters = "<>" })),
}

ls.add_snippets("lua", lua_snippets)

local all_snippets = {
  s("todo", fmt("TODO(yc): {}", { i(0, "text") })),
}

ls.add_snippets("all", all_snippets)
