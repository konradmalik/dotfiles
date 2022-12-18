-- this is opt
local load_dap = function()
    vim.cmd [[packadd! nvim-dap]]
    vim.cmd [[packadd! nvim-dap-ui]]
    vim.cmd [[packadd! nvim-dap-virtual-text]]
    require("konrad.dap")
end

vim.api.nvim_create_user_command('EnableDAP', load_dap, { nargs = 0 })
