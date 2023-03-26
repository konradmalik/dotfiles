local group_name = "teej-automagic"

local attach_to_buffer = function(output_bufnr, pattern, command)
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup(group_name, { clear = true }),
        pattern = pattern,
        callback = function()
            local append_data = function(_, data)
                if data then
                    vim.api.nvim_buf_set_lines(output_bufnr, -1, -1, false, data)
                end
            end

            vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { "AutoMagic output:" })
            vim.fn.jobstart(command, {
                stdout_buffered = true,
                on_stdout = append_data,
                on_stderr = append_data,
            })
        end,
    })
end

vim.api.nvim_create_user_command("AutoMagicStart", function()
    print("AutoMagic starts now...")
    local bufnr = vim.fn.input("Bufnr: ")
    local pattern = vim.fn.input("Pattern: ")
    local command = vim.fn.input("Command: ")
    attach_to_buffer(tonumber(bufnr), pattern, vim.split(command, " "))
end, {
    desc = "Starts AutoMagic functionality with interactive setup",
})

vim.api.nvim_create_user_command("AutoMagicStop", function()
    print("AutoMagic stops now...")
    vim.api.nvim_create_augroup(group_name, { clear = true })
end, {
    desc = "Stops AutoMagic functionality",
})
