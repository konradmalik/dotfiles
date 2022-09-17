local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
    vim.notify("cannot load dap")
    return
end

local dapui_ok, dapui = pcall(require, "dapui")
if not dapui_ok then
    vim.notify("cannot load dapui")
    return
end

local map = function(lhs, rhs, desc)
    if desc then
        desc = "[DAP] " .. desc
    end

    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

map("<leader>dc", dap.continue)
map("<leader>dsv", dap.step_over)
map("<leader>dsi", dap.step_into)
map("<leader>dso", dap.step_out)
map("<leader>dr", dap.repl.open)
map("<leader>db", dap.toggle_breakpoint)
map("<leader>dB", function()
    dap.set_breakpoint(vim.fn.input "[DAP] Condition > ")
end)

map("<leader>de", dapui.eval)
map("<leader>dE", function()
    dapui.eval(vim.fn.input "[DAP] Expression > ")
end)
