local lsp = require("konrad.lsp")
lsp.add("nil_ls")

local null = require("null-ls")
lsp.add("null-ls", null.builtins.formatting.nixpkgs_fmt)
