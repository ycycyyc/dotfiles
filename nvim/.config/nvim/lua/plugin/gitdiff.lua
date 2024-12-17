local plugin = {}

plugin.init = function()
  ---@param commit string | nil
  YcVim.git.commit_diff = function(commit)
    if not commit then
      vim.cmd "DiffviewOpen"
      return
    end

    local idx = vim.fn.stridx(commit, "^") ---@type number
    local cmd = "" ---@type string

    if idx >= 0 then
      vim.notify "it's first commit"
      cmd = "DiffviewOpen " .. commit
    else
      cmd = "DiffviewOpen " .. commit .. "^!"
    end

    vim.notify("Run cmd: " .. cmd)
    vim.cmd(cmd)
  end

  ---@param file string
  YcVim.git.file_diff = function(file)
    local cmd = "DiffviewOpen -- " .. file
    vim.notify("Run cmd: " .. cmd)
    vim.cmd(cmd)
  end
end

plugin.initfuncs = {
  {
    { "DiffviewFiles", "DiffviewFileHistory" },
    function()
      local close = function()
        vim.cmd "DiffviewClose"
        vim.cmd "silent! checktime"
      end

      YcVim.map.buf("n", "<leader>q", close)
      YcVim.map.buf("n", "q", close)
      YcVim.map.buf("n", "<esc>", close)
    end,
  },
}

return {
  "sindrets/diffview.nvim",
  init = plugin.init,
  keys = {
    {
      YcVim.keys.git_diff_file,
      function()
        local file = vim.fn.expand "%:~:."
        vim.cmd("DiffviewFileHistory " .. file)
      end,
    },
    {
      YcVim.keys.git_diff_open,
      ":DiffviewOpen<cr>",
    },
  },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewFocusFiles" },
  config = function()
    local opt = require "plugin.gitdiff_opt"
    require("diffview").setup(opt)
    YcVim.setup_m(plugin)
  end,
}
