---@type YcVim.SetupOpt
local setup = {}

setup.initfuncs = {
  {
    "qf",
    function()
      YcVim.keys.buf_map("n", "q", ":q<cr>")
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

setup.user_cmds = {
  {
    "BufOnly",
    function()
      YcVim.util.buf_only()
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
  {
    "ShowEnvHash",
    function()
      vim.notify(vim.inspect(YcVim.env_hash))
    end,
    {},
  },
}

YcVim.setup(setup)
