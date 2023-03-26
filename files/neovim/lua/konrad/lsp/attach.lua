local lsp = require("konrad.lsp.lsp")
local navic = require("konrad.lsp.navic")

return function(client, bufnr)
    -- builtin lsp
    lsp(client, bufnr)
    -- navigation bar
    navic(client, bufnr)
end
