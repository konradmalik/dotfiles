local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
    vim.notify("cannot load dap")
    return
end

dap.adapters.debugpy = {
    type = 'executable';
    command = 'python';
    args = { '-m', 'debugpy.adapter' };
    options = {
        source_filetype = 'python',
    },
}

local get_python_path = function()
    -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
    -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
    -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
    local cwd = vim.fn.getcwd()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv then
        return string.format("%s/bin/python", venv)
    elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
    elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
    else
        return '/usr/bin/python'
    end
end

dap.configurations.python = {
    {
        -- The first three options are required by nvim-dap
        type = 'debugpy'; -- the type here established the link to the adapter definition: `dap.adapters.debugpy`
        request = 'launch';
        name = "Launch file";
        -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
        program = "${file}"; -- This configuration will launch the current file if used.
        pythonPath = get_python_path;
    },
    {
        type = 'debugpy';
        request = 'launch';
        name = 'Launch file with arguments';
        program = '${file}';
        args = coroutine.create(function(dap_run_co)
            vim.ui.input({
                prompt = 'Args:',
            }, function(input)
                coroutine.resume(dap_run_co, input)
            end)
        end),
        pythonPath = get_python_path;
    },
    {
        type = 'debugpy';
        request = 'launch';
        name = 'Launch pytest on file';
        module = 'pytest',
        args = { '-s', '${file}' };
        pythonPath = get_python_path;
    }
}
