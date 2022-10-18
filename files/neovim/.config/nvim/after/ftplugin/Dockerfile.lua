local dockerfile = vim.api.nvim_create_augroup("konrad_ftdockerfile", { clear = true })

-- crashes on macos and not on linux for some reason, so disable it
local disable_treesitter_context = function() vim.cmd("TSContextDisable") end

local callback = function()
    disable_treesitter_context()
end

vim.api.nvim_create_autocmd({ "BufEnter" },
    { pattern = { "*/Earthfile" }, callback = callback, group = dockerfile })
