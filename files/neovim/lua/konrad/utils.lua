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

---@param ... string
---@return boolean
function utils.has_bins(...)
    for i = 1, select("#", ...) do
        if 0 == vim.fn.executable((select(i, ...))) then
            return false
        end
    end
    return true
end

---@param String string
---@param Start string
---@return boolean
function utils.stringstarts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

---@param name string
---@param packadds string[]
---@param fun function
---@param opts table|nil
---@param delete boolean|nil
function utils.make_enable_command(name, packadds, fun, opts, delete)
    vim.api.nvim_create_user_command(name, function()
        if delete then
            vim.api.nvim_del_user_command(name)
        end
        for _, value in ipairs(packadds) do
            vim.cmd('packadd ' .. value)
        end
        fun()
    end, opts or {});
end

---@param config table Can be obtained by getting the 'client' object in some way and calling 'client.config'
---@return boolean
function utils.is_matching_filetype(config)
    local ft = vim.bo.filetype or ''
    return ft ~= '' and utils.has_value(config.filetypes or {}, ft)
end

return utils
