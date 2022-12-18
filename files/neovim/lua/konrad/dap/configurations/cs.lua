local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
    vim.notify("cannot load dap")
    return
end

local utils = require("konrad.utils")

dap.adapters.netcoredbg = {
    type = 'executable',
    command = 'netcoredbg',
    args = { '--interpreter=vscode' }
}

dap.configurations.cs = {
    {
        type = "netcoredbg",
        name = "Launch file",
        request = "launch",
        program = utils.make_get_input({
            prompt = 'Path to dll: ',
            default = vim.fn.getcwd() .. '/bin/Debug/',
            completion = 'file',
        }),
    },
}
