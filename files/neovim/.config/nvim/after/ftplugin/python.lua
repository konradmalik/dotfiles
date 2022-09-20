local python = vim.api.nvim_create_augroup("konrad_ftpython", { clear = true })

local disable_diagnostics = function() vim.diagnostic.disable(0) end
vim.api.nvim_create_autocmd({ "BufEnter" },
    { pattern = { "*/Tiltfile" }, callback = disable_diagnostics, group = python })
