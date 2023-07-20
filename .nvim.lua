local lsp = require("konrad.lsp")
lsp.add("nil_ls")
-- lsp.add("nixd")

lsp.add("null-ls", function(null)
    return {
        null.builtins.formatting.nixpkgs_fmt
    } end)
