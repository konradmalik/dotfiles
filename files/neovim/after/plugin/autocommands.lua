local utils = require("konrad.utils")

local personal = vim.api.nvim_create_augroup("personal", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", { callback = utils.trim_trailing_whitespace, group = personal })
