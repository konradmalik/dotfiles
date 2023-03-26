local trim_is_enabled = true
vim.api.nvim_create_user_command('AutoTrimToggle', function()
    trim_is_enabled = not trim_is_enabled
    print('Setting autotrim to: ' .. tostring(trim_is_enabled))
end, {
    desc = "Enable/disable autotrimming whitespace on buffer save",
})

-- Deletes all trailing whitespaces in a file if it's not binary nor a diff.
local trim_trailing_whitespace = function()
    if not vim.bo.binary and vim.bo.filetype ~= "diff" then
        local current_view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(current_view)
    end
end

local group = vim.api.nvim_create_augroup("personal-autotrim", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
        if not trim_is_enabled then
            return
        end
        trim_trailing_whitespace()
    end,
    group = group
})
