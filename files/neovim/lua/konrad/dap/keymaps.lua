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

map("<leader>dc", dap.continue, "continue")
map("<leader>dsv", dap.step_over, "step over")
map("<leader>dsi", dap.step_into, "step into")
map("<leader>dso", dap.step_out, "step out")
map("<leader>dr", dap.repl.open, "repl")
map("<leader>db", dap.toggle_breakpoint, "toggle breakpoint")
map("<leader>dB", function()
    dap.set_breakpoint(vim.ui.input("[DAP] Condition > "))
end, "conditional breakpoint")

map("<leader>de", dapui.eval, "evaluate")
map("<leader>dE", function()
    dapui.eval(vim.ui.input("[DAP] Expression > "))
end, "evaluate interactive")
