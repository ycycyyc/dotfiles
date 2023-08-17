---@alias Yc.KeyMapTbl table<string, table>

---@class Yc.LspConf
---@field auto_format boolean

---@alias Yc.ClientLspConfCb fun(client:table, bufnr:number, kms:Yc.KeyMapTbl, lsp_config: Yc.LspConf)

---@class Yc.LspOnAttachConf
---@field client_cb Yc.ClientLspConfCb
