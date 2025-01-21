if YcVim.env.pick == "fzf" then
  return require "plugin.fzf_lua"
end

local hidden = false
local cwd = vim.uv.cwd()
if cwd and string.match(cwd, "dotfiles") then
  hidden = true
end

local confirm = function(picker, item)
  local sel = picker:selected()
  if #sel > 1 then
    picker:action "qflist"
    return
  end
  -- lua/snacks/picker/actions.lua
  picker:action "jump"
end

local lsp_method = YcVim.lsp.method
lsp_method.references = function()
  require("snacks").picker.lsp_references {
    auto_confirm = false,
    actions = { confirm = confirm },
  }
end

lsp_method.definition = function()
  require("snacks").picker.lsp_definitions {
    actions = { confirm = confirm },
  }
end

lsp_method.impl = function()
  require("snacks").picker.lsp_implementations {
    auto_confirm = false,
    actions = { confirm = confirm },
  }
end

---@param find YcVim.Finder
local grep = function(find)
  local opt = {
    live = find.islive,
    regex = false,
    search = find.query,
    ft = find.fts,
    hidden = hidden,
    limit = find.limit,
    actions = { confirm = confirm },
  }

  if find.filepath then
    opt.dirs = { find.filepath }
  end

  require("snacks").picker.grep(opt)
end

---@type YcVim.SetupOpt
local setup = {}

setup.user_cmds = {
  { "Rg", YcVim.rg.run(grep, grep), { nargs = "*", bang = true } },
}

YcVim.setup(setup)

local keys = YcVim.keys

return {
  "folke/snacks.nvim",
  keys = {
    { keys.pick_open, "<cmd>lua Snacks.picker()<cr>" },
    { keys.pick_resume, "<cmd>lua Snacks.picker.resume()<cr>" },
    {
      keys.pick_files,
      function()
        require("snacks").picker.files { hidden = hidden }
      end,
    },
    {
      keys.pick_lines,
      function()
        require("snacks").picker.lines { layout = { preview = false } }
      end,
    },
    { keys.pick_grep, ":Rg " },
    { keys.pick_grep_word, ":Rg <c-r><c-w><cr>" },
    {
      keys.pick_grep_word_cur_buf,
      function()
        require("snacks").picker.lines {
          layout = { preview = false },
          pattern = "'" .. vim.fn.expand "<cword>",
        }
      end,
    },
    { keys.lsp_symbols, "<cmd>lua Snacks.picker.lsp_symbols()<cr>" },
    {
      keys.pick_cmd_history,
      function()
        require("snacks").picker.command_history {}
      end,
    },
    {
      keys.git_commits,
      function()
        require("snacks").picker.git_log {
          actions = {
            confirm = function(picker, item)
              picker:close()
              YcVim.git.commit_diff(item.commit)
            end,
          },
        }
      end,
    },
  },
  opts = {
    picker = {
      icons = {
        ui = {
          live = "Live",
          hidden = "h",
          ignored = "i",
          selected = "▌",
          unselected = " ",
        },
      },
      win = {
        preview = { wo = { cursorlineopt = "both" } },
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "i", "n" } },
            ["<c-f>"] = { "<right>", mode = { "i" }, expr = true },
            ["<c-a>"] = { "<c-o>0", mode = { "i" }, expr = true },
            ["<a-a>"] = { "select_all", mode = { "n", "i" } },
          },
        },
      },
      layouts = {
        ycvim = {
          layout = {
            box = "vertical",
            width = 0.8,
            height = 0.9,
            zindex = 50,
            { win = "preview", title = "{preview}", border = "rounded" },
            {
              box = "vertical",
              border = "rounded",
              title = "{source} {live} {flags}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
            },
          },
        },
      },
      layout = { cycle = false, preset = "ycvim" },
    },
  },
}
