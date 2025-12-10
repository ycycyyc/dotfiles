local keys = YcVim.keys

local hidden = false
local cwd = vim.uv.cwd()
if cwd and string.match(cwd, "dotfiles") then
  hidden = true
end

local confirm = function(picker, _)
  local sel = picker:selected()
  if #sel > 1 then
    picker:action "qflist"
    return
  end
  -- lua/snacks/picker/actions.lua
  picker:action "jump"
end

vim.keymap.set("n", keys.toggle_term, function()
  local snacks = require "snacks"
  snacks.terminal.toggle(nil, {
    win = {
      on_buf = function(win)
        vim.keymap.set("t", keys.toggle_term, function()
          snacks.terminal.toggle()
        end, { buffer = win.buf, nowait = true })
      end,
      border = "rounded",
      position = "float",
      backdrop = 100,
      width = 0.85,
      height = 0.8,
      wo = { winhighlight = "Normal:Normal" },
    },
  })

  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("User", { pattern = "LineRefresh" })
  end, 0)
end)

local lsp_action = YcVim.lsp.action
lsp_action.references = function()
  require("snacks").picker.lsp_references {
    include_current = true,
    auto_confirm = false,
    actions = { confirm = confirm },
  }
end

lsp_action.definition = function()
  require("snacks").picker.lsp_definitions {
    include_current = true,
    actions = { confirm = confirm },
  }
end

lsp_action.impl = function()
  require("snacks").picker.lsp_implementations {
    auto_confirm = false,
    include_current = true,
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
  {
    "SnacksShowHistory",
    ":lua Snacks.notifier.show_history()<cr>",
    {},
  },
}

YcVim.setup(setup)

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
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
        require("snacks").picker.lines { layout = { preview = true, preset = "ycvim" } }
      end,
    },
    { keys.pick_grep, ":Rg " },
    { keys.pick_grep_word, ":Rg <c-r><c-w><cr>" },
    {
      keys.pick_grep_word_cur_buf,
      function()
        require("snacks").picker.lines {
          layout = { preview = true, preset = "ycvim" },
          pattern = "'" .. vim.fn.expand "<cword>",
        }
      end,
    },
    { keys.lsp_symbols, "<cmd>lua Snacks.picker.lsp_symbols()<cr>" },
    { keys.lsp_diagnostics, "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>" },
    {
      keys.pick_cmd_history,
      function()
        require("snacks").picker.command_history {
          layout = { preview = false, preset = "select" },
        }
      end,
    },
    {
      keys.git_logs,
      function()
        require("snacks").picker.git_log {
          actions = {
            confirm = function(_, item)
              vim.schedule(function()
                YcVim.git.commit_diff(item.commit)
              end)
            end,
          },
        }
      end,
    },
  },
  config = function(_, opts)
    local snacks = require "snacks"
    snacks.setup(opts)
    snacks.config.style("notification", { wo = { winblend = 0 } }) -- 避免notifier和代码重叠
  end,
  opts = {
    input = {
      win = {
        relative = "cursor",
        row = -3,
        col = 0,
        keys = {
          i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i" },
        },
      },
      icon = ">",
    },
    notifier = {
      enabled = true,
      -- padding = false,
      icons = {
        error = "E ",
        warn = "W ",
        info = "I ",
        debug = "E ",
        trace = "T ",
      },
      margin = { top = 1, right = 1, bottom = 1 },
    },
    picker = {
      toggles = {
        hidden = "Hidden[m-d]",
        ignored = "Ignored[m-g]",
        regex = { icon = "Regex[m-r]", value = true },
      },
      icons = {
        ui = {
          live = "Live[c-g]",
          hidden = "Hidden",
          ignored = "Ignored",
          selected = "▌",
          unselected = " ",
        },
      },
      win = {
        -- preview = { wo = { cursorlineopt = "screenline" } }, -- bug: 跳转的时候会修改cursorlineopt
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "i", "n" } },
            ["<c-f>"] = { "<right>", mode = { "i" }, expr = true },
            ["<c-a>"] = { "<Home>", mode = { "i" }, expr = true },
            ["<a-a>"] = { "select_all", mode = { "n", "i" } },
            ["<c-u>"] = { "<c-s-u>", mode = { "i" }, expr = true },
            ["<a-f>"] = { "<S-Right>", mode = { "i" }, expr = true },
            ["<a-b>"] = { "<S-Left>", mode = { "i" }, expr = true },
            ["<a-g>"] = { "toggle_ignored", mode = { "i", "n" } },
            ["<a-d>"] = { "toggle_hidden", mode = { "i", "n" } },
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
      formatters = { file = { truncate = 999 } }, -- don't trancate file name
      layout = { cycle = false, preset = "ycvim" },
    },
  },
}
