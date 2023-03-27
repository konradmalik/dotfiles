local group = vim.api.nvim_create_augroup("personal-skeletons", { clear = true })

local insert_skeleton = function(name)
    vim.cmd("0r " .. vim.fn.stdpath "config" .. "/skeletons/" .. name)
end

vim.api.nvim_create_autocmd({ "BufNewFile" }, {
    group    = group,
    pattern  = ".nvim.lua",
    callback = function()
        insert_skeleton(".nvim.lua")
    end
})
