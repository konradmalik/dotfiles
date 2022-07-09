local utils = require('user.utils')

local personal = vim.api.nvim_create_augroup("personal", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", { callback = utils.trim_trailing_whitespace, group = personal })

local lldiagnostics = function() vim.diagnostic.setloclist({ open = false }) end
vim.api.nvim_create_autocmd("DiagnosticChanged", { callback = lldiagnostics, group = personal })

local packer_user_config = vim.api.nvim_create_augroup("packer_user_config", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost",
    { command = "source <afile> | PackerSync", pattern = "plugins.lua", group = packer_user_config })
