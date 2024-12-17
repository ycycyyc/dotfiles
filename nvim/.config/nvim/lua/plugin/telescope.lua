local M = {}

local keys = YcVim.keys
local keyset = vim.keymap.set
local last_rg
local last_grep_string_prompt = ""

M.config = function() end

M.telescope_config = function()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local builtin = require "telescope.builtin"

  local select_multi = function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)

    local qf_entries = {}
    for _, entry in ipairs(picker:get_multi_selection()) do
      table.insert(qf_entries, entry)
    end

    if #qf_entries > 0 then
      (actions.send_selected_to_qflist + actions.open_qflist)(prompt_bufnr)
      return
    end

    actions.select_default(prompt_bufnr)
  end

  require("telescope").setup {
    defaults = {
      layout_strategy = "vertical",
      layout_config = {
        height = 0.99,
        preview_height = 0.4,
        vertical = {
          prompt_position = "top",
        },
      },
      sorting_strategy = "ascending",
      mappings = {
        i = {
          ["<c-j>"] = actions.move_selection_next, -- TODO(nop)
          ["<c-k>"] = actions.move_selection_previous,
          ["<c-l>"] = actions.send_to_qflist + actions.open_qflist,
          ["<esc>"] = actions.close,
          ["<cr>"] = select_multi,
        },
      },
    },
    pickers = {
      find_files = {},
      grep_string = {
        mappings = {
          i = {
            ["<c-g>"] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local str = picker.prompt_title
              local pattern = "Find Word %((.-)%)"
              local match = string.match(str, pattern)

              if match ~= "" then
                local prompt = picker:_get_prompt()
                last_grep_string_prompt = prompt

                actions.close(prompt_bufnr)

                vim.schedule(function()
                  builtin.live_grep {
                    vimgrep_arguments = last_rg,
                    default_text = match,
                  }
                end)
              else
                vim.print "No match found"
              end
            end,
          },
        },
      },
      live_grep = {
        mappings = {
          i = {
            ["<c-g>"] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local prompt = picker:_get_prompt()
              if prompt ~= "" then
                actions.close(prompt_bufnr)

                vim.schedule(function()
                  builtin.grep_string {
                    vimgrep_arguments = last_rg,
                    search = prompt,
                    default_text = last_grep_string_prompt,
                  }
                end)
              end
            end,
          },
        },
      },
      current_buffer_fuzzy_find = {},
      git_commits = {
        mappings = {
          i = {
            ["<cr>"] = function(bufnr)
              local selection = action_state.get_selected_entry()
              if selection and selection.value then
                actions.close(bufnr)
                vim.schedule(function()
                  YcVim.git.commit_diff(selection.value)
                end)
              end
            end,
          },
        },
      },
      command_history = {},
    },
    extensions = {
      fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case", -- or "ignore_case" or "respect_case"
      },
      coc = {
        prefer_locations = false,
      },
    },
  }

  vim.keymap.set("n", keys.search_find_files, builtin.find_files, { silent = true })
  vim.keymap.set("n", keys.search_resume, builtin.resume, { silent = true })
  vim.keymap.set("n", keys.search_cur_word, builtin.grep_string, { silent = true })
  vim.keymap.set("n", keys.git_commits, builtin.git_commits, { silent = true })
  vim.keymap.set("n", keys.cmd_history, builtin.command_history, { silent = true })

  require("telescope").load_extension "fzf"
  require("telescope").load_extension "coc"

  keyset("n", keys.lsp_hover, show_docs, { silent = true })
  keyset("n", keys.lsp_goto_definition, ":Telescope coc definitions<cr>", { silent = true })
  keyset("n", keys.lsp_goto_references, ":Telescope coc references<cr>", { silent = true })
  keyset("n", keys.lsp_goto_type_definition, ":Telescope coc type_definitions<cr>", { silent = true })
  keyset("n", keys.lsp_impl, ":Telescope coc implementations<cr>", { silent = true })
  keyset("n", keys.lsp_symbols, ":Telescope coc document_symbols<cr>", { silent = true })
  keyset("n", keys.lsp_rename, "<Plug>(coc-rename)", { silent = true })
  keyset("n", keys.lsp_code_action, ":Telescope coc line_code_actions<cr>", { silent = true })
  keyset("n", keys.lsp_err_goto_prev, "<Plug>(coc-diagnostic-prev)", { silent = true })
  keyset("n", keys.lsp_err_goto_next, "<Plug>(coc-diagnostic-next)", { silent = true })

  vim.api.nvim_create_user_command("Rg", function(args)
    ---@type string[]
    local rg = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--glob=!.git/",
      "--hidden",
    }

    ---@type string[]
    local fargs = args["fargs"]
    ---@type string[]
    local content = {}
    ---@type 0 | 1
    local ignore = 0
    ---@type boolean
    local islive = false
    ---@type string
    local filepath = ""

    -- TODO(yc) grep 'main -t' 怎么处理?
    for i, value in ipairs(fargs) do
      if ignore > 0 then
        ignore = 0
      elseif value == "-t" then
        ignore = 1
        if fargs[i + 1] == "go" then
          table.insert(rg, "--type=go")
        elseif fargs[i + 1] == "cpp" then
          table.insert(rg, "--type=cpp")
          table.insert(rg, "--type=c")
        elseif fargs[i + 1] == "lua" then
          table.insert(rg, "--type=lua")
        elseif fargs[i + 1] == "vim" then
          table.insert(rg, "--type=vim")
        end
      elseif value == "-g" then
        ignore = 1
        table.insert(rg, "--glob=" .. fargs[i + 1])
      elseif value == "-i" then
        islive = true
      elseif value == "--" then
        ignore = 1
        filepath = fargs[i + 1]
      else
        table.insert(content, value)
      end
    end

    if filepath ~= "" then
      -- table.insert(rg, "--")
      -- table.insert(rg, filepath)
      -- TODO
    end

    ---@type string
    local query = table.concat(content, " ")
    last_rg = rg
    last_grep_string_prompt = ""

    if query == "" then
      islive = true
      builtin.live_grep {
        vimgrep_arguments = rg,
      }
      return
    end

    if islive then
      builtin.live_grep {
        vimgrep_arguments = rg,
        default_text = query,
      }
      return
    end

    builtin.grep_string {
      vimgrep_arguments = rg,
      search = query,
    }
  end, { nargs = "*", bang = true })

  keyset("n", keys.search_global, ":Rg ")
  keyset("n", keys.search_buffer, builtin.current_buffer_fuzzy_find)
end

return M
