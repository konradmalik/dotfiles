local utils = {}

function utils.first_to_upper(str)
    return str:gsub("^%l", string.upper)
end

-- check if array-like table has a value
---@param tab any[]
---@param val any
---@return boolean
function utils.has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

---@param ... string|string[]
---@return boolean
function utils.has_bins(...)
    for i = 1, select("#", ...) do
        if 0 == vim.fn.executable((select(i, ...))) then
            return false
        end
    end
    return true
end

---@param name string
---@param packadds string[]
---@param fun function
---@param opts table|nil
function utils.make_enable_command(name, packadds, fun, opts)
    vim.api.nvim_create_user_command(name, function()
        for _, value in ipairs(packadds) do
            vim.cmd('packadd ' .. value)
        end
        fun()
        vim.api.nvim_del_user_command(name)
    end, opts or {});
end

return utils
