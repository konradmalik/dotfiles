local utils = require("konrad.utils")

local personal = vim.api.nvim_create_augroup("personal", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", { callback = utils.trim_trailing_whitespace, group = personal })

local lldiagnostics = function() vim.diagnostic.setloclist({ open = false }) end
-- local qfdiagnostics = function() vim.diagnostic.setqflist({ open = false }) end
vim.api.nvim_create_autocmd("DiagnosticChanged", { callback = lldiagnostics, group = personal })
