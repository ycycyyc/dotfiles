---@alias Yc.KeyMapTbl table<string, table>

---@class Yc.LspConf
---@field auto_format boolean

---@alias Yc.ClientLspConfFunc fun(keymaps:Yc.KeyMapTbl, lsp_config: Yc.LspConf)

---@class Yc.LspOnAttachOpts
---@field config Yc.ClientLspConfFunc
