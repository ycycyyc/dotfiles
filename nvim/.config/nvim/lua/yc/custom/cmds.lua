local plugin = {}

plugin.initfuncs = {
  {
    "qf",
    function()
      YcVim.map.buf("n", "q", ":q<cr>")
      vim.cmd.wincmd "J"
    end,
  },
  {
    "help",
    function()
      vim.cmd.wincmd "L"
    end,
  },
}

plugin.user_cmds = {
  {
    "BufOnly",
    function()
      require("utils.helper").buf_only()
      vim.api.nvim_exec_autocmds("User", {
        pattern = "LineRefresh",
      })
    end,
    {},
  },

  {
    "CpFilePath",
    function()
      local path = vim.fn.expand "%:~:."
      vim.notify("copy path: " .. path, vim.log.levels.INFO)
      vim.fn.setreg("0", path)
      vim.fn.setreg('"', path)
    end,
    {},
  },
}

YcVim.setup_m(plugin)
