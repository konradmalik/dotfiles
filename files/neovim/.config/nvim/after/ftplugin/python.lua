local python = vim.api.nvim_create_augroup("konrad_ftpython", { clear = true })

local disable_diagnostics = function() vim.diagnostic.disable(0) end
local disable_nullls_diagnostics = function()
    -- disable all null-ls disagnostic providers
    local null_ls_ok, null_ls = pcall(require, "null-ls")
    if not null_ls_ok then
        vim.notify("cannot load null-ls")
        return
    end

    null_ls.disable({ method = null_ls.methods.DIAGNOSTICS })
end

local callback = function()
    disable_diagnostics()
    disable_nullls_diagnostics()
end
vim.api.nvim_create_autocmd({ "BufEnter" },
    { pattern = { "*/Tiltfile" }, callback = callback, group = python })
