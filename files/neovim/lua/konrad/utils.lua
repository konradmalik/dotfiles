local utils = {}
local o = vim.o
local fn = vim.fn
local cmd = vim.cmd
local g = vim.g

-- Deletes all trailing whitespaces in a file if it's not binary nor a diff.
function utils.trim_trailing_whitespace()
    if not o.binary and o.filetype ~= "diff" then
        local current_view = fn.winsaveview()
        cmd([[keeppatterns %s/\s\+$//e]])
        fn.winrestview(current_view)
    end
end

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

-- interactively get user's input
-- opts can have: prompt, default, completion and more, see :h input
function utils.make_get_input_split(opts)
    return function()
        local co = coroutine.running()
        if co then
            return coroutine.create(function()
                local args = {}
                vim.ui.input(opts, function(input)
                    args = vim.split(input or "", " ")
                end)
                coroutine.resume(co, args)
            end)
        else
            local args = {}
            vim.ui.input(opts, function(input)
                args = vim.split(input or "", " ")
            end)
            return args
        end
    end
end

function utils.make_get_input(opts)
    return function()
        local co = coroutine.running()
        if co then
            return coroutine.create(function()
                local args = ""
                vim.ui.input(opts, function(input)
                    args = input
                end)
                coroutine.resume(co, args)
            end)
        else
            local args = ""
            vim.ui.input(opts, function(input)
                args = input
            end)
            return args
        end
    end
end

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
