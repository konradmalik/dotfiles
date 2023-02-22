local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
    vim.notify("cannot load dap")
    return
end


dap.adapters.delve = {
    type = 'server',
    port = '${port}',
    executable = {
        command = 'dlv',
        args = { 'dap', '-l', '127.0.0.1:${port}' },
    }
}

dap.configurations.go = {
    {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "${file}"
    },
    {
        type = "delve",
        name = "Debug (Arguments)",
        request = "launch",
        program = "${file}",
        args = coroutine.create(function(dap_run_co)
            vim.ui.input({
                prompt = 'Args:',
            }, function(input)
                coroutine.resume(dap_run_co, input)
            end)
        end),
    },
    {
        type = "delve",
        name = "Debug Package",
        request = "launch",
        program = "${fileDirname}",
    },
    {
        type = "delve",
        name = "Debug test", -- configuration for debugging test files
        request = "launch",
        mode = "test",
        program = "${file}"
    },
    -- works with go.mod packages and sub packages
    {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${relativeFileDirname}"
    }
}
