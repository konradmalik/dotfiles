local utils = {}
local cmd = vim.cmd
local g = vim.g

function utils.first_to_upper(str)
    return str:gsub("^%l", string.upper)
end

-- check if array-like table has a value
function utils.has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- TODO make better via the same mechanism as autoformat
-- the_primeagen's quickfix toggler
-- local list
g.the_primeagen_qf_l = 0
-- global quick fix
g.the_primeagen_qf_g = 0

function utils.ToggleQFList(global)
    if global == 1 then
        if g.the_primeagen_qf_g == 1 then
            g.the_primeagen_qf_g = 0
            cmd("cclose")
        else
            g.the_primeagen_qf_g = 1
            cmd("copen")
        end
    else
        if g.the_primeagen_qf_l == 1 then
            g.the_primeagen_qf_l = 0
            cmd("lclose")
        else
            g.the_primeagen_qf_l = 1
            if not pcall(function() vim.cmd("lopen") end) then
                vim.notify("no location list")
            end
        end
    end
end

function utils.has_bins(...)
    for i = 1, select("#", ...) do
        if 0 == vim.fn.executable((select(i, ...))) then
            return false
        end
    end
    return true
end

return utils
