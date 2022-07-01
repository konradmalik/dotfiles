local utils = require('user.utils')

local autocmds = {
    personal = {
        { "BufWritePre", "*", "lua require('user.utils').trim_trailing_whitespace()" },
        { "DiagnosticChanged", "*", "lua vim.diagnostic.setloclist({ open = false })" },
    },
    packer_user_config = {
        { "BufWritePost", "plugins.lua", "source <afile> | PackerSync" },
    },
}

utils.nvim_create_augroups(autocmds)
