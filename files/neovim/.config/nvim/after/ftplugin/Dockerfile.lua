local dockerfile = vim.api.nvim_create_augroup("konrad_ftdockerfile", { clear = true })

local disable_diagnostics = function() vim.diagnostic.disable(0) end
vim.api.nvim_create_autocmd({ "BufEnter" },
    { pattern = { "*/Earthfile" }, callback = disable_diagnostics, group = dockerfile })
