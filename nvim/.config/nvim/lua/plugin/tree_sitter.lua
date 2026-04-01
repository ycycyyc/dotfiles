local ensure_installed = { "cpp", "go", "lua", "c", "java", "python" }
if vim.fn.has "mac" == 1 then
  ensure_installed = { "cpp", "go", "java", "python" }
end

-- main分支, 需要手动开启
vim.api.nvim_create_autocmd({ "Filetype" }, {
  callback = function(event)
    -- make sure nvim-treesitter is loaded
    local ok, nvim_treesitter = pcall(require, "nvim-treesitter")

    -- no nvim-treesitter, maybe fresh install
    if not ok then
      return
    end

    local parsers = require "nvim-treesitter.parsers"

    if not parsers[event.match] or not nvim_treesitter.install then
      return
    end

    local ft = vim.bo[event.buf].ft
    local lang = vim.treesitter.language.get_lang(ft)

    local installed_langs = nvim_treesitter.get_installed()
    if vim.tbl_contains(installed_langs, lang) == true then
      pcall(vim.treesitter.start, event.buf)
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

-- cargo install --locked tree-sitter-cli
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ok, nvim_treesitter = pcall(require, "nvim-treesitter")
    if not ok then
      return
    end

    nvim_treesitter.install(ensure_installed)
  end,
}
