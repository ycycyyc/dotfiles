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

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local m = extras.m
local l = extras.l
local postfix = require("luasnip.extras.postfix").postfix
local conds = require "luasnip.extras.conditions"
local conds_expand = require "luasnip.extras.conditions.expand"

local function copy(args)
  return args[1]
end

local snippets = {
  s("json", { t '`json:"', i(0, "text"), t '"`' }),
  s("bson", { t '`bson:"', i(0, "text"), t '"`' }),
  s("yaml", { t '`yaml:"', i(0, "text"), t '"`' }),
  s("wg", { t "wg sync.WaitGroup" }),
  -- s("infof", { t 'Infof("', i(1, "string"), t ':%v", ', i(2, "val"), t ")" }, {
  --   show_condition = function(line_to_cursor)
  --     return vim.fn.matchstr(line_to_cursor, "log.") ~= ""
  --   end,
  -- }),
  -- s("errorf", { t 'Errorf("', i(1, "msg"), t ' :%v", ', i(2, "err"), t ")" }, {
  --   show_condition = function(line_to_cursor)
  --     return vim.fn.matchstr(line_to_cursor, "fmt.") ~= ""
  --   end,
  -- }),
  s("map", { t "map[", i(1, "type"), t "]", i(0) }),
  s("pkgm", fmt("package main\n\nfunc main() {}\n\t {} \n{}", { t "{", i(0), t "}" })),
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
        f(copy, 1),
        t "<",
        i(3, "count"),
        f(copy, 1),
        i(4, "++"),
        i(5),
      },
      { delimiters = "<>" }
    )
  ),
  s(
    "forrange",
    fmt(
      [[
      for <>, <> := range <> {
          <>
      }
      ]],
      { i(1, "_"), i(2, "val"), i(3, "obj"), i(0) },
      { delimiters = "<>" }
    )
  ),
}

ls.add_snippets("go", snippets)

local all_snippets = {
  s("todo", fmt("TODO(yc): {}", { i(0, "text") })),
}

ls.add_snippets("all", all_snippets)
