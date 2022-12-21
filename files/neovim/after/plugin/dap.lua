vim.api.nvim_create_user_command("DapInit", function()
    require("konrad.dap")
end, {});
