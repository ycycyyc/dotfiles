require("trouble").setup {
  mode = "document_diagnostics",
  icons = false,
  fold_open = "", -- icon used for open folds
  fold_closed = ">", -- icon used for closed folds
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
  signs = {
    -- icons / text used for a diagnostic
    error = "ERRO",
    warning = "WARN",
    hint = "HINT",
    information = "INFO",
    other = "OT",
  },
}
