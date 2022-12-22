vim.api.nvim_create_user_command("DapInit", function()
    vim.api.nvim_command('packadd nvim-dap')
    vim.api.nvim_command('packadd nvim-dap-ui')
    vim.api.nvim_command('packadd nvim-dap-virtual-text')
    require("konrad.dap")
end, {});
