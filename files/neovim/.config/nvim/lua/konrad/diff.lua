local status_ok, gitsigns = pcall(require, "gitsigns")
if not status_ok then
    vim.notify("gitsigns cannot be initialized!")
    return
end
local icons = require("konrad.icons")

local function get_all_commits_of_this_file()
    -- git log --pretty=format:"%h %an %ad  %s" --date relative --follow
    -- git log --pretty=oneline --abbrev-commit --follow
    local scripts = vim.api.nvim_exec('!git log --pretty=format:"\\%h \\%an \\%ad  \\%s" --date relative --follow %',
        true)
    local res = vim.split(scripts, "\n")
    -- remove first 2 elements - the command itself and an empty line
    table.remove(res, 1)
    table.remove(res, 1)

    local output = {}
    for i, item in ipairs(res) do
        local hash_id = vim.trim(string.sub(item, 1, 7))
        local text = vim.trim(string.sub(item, 8))
        output[i] = { hash_id = hash_id, text = text }
    end
    return output
end

local function diff_with()
    local commits = get_all_commits_of_this_file();

    vim.ui.select(commits, {
        prompt = "Select commit to compare with current file",
        format_item = function(item)
            return string.format("%s %s %s", icons.git.Commit, item.hash_id, item.text)
        end,
    }, function(choice)
        gitsigns.diffthis(choice.hash_id)
        -- With vim-fugitive
        -- vim.cmd("Gvdiffsplit " .. choice.hash_id)
    end)
end

return diff_with
