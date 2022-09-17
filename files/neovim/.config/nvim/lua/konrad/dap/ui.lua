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

local icons = require("konrad.icons")

dapui.setup({
    icons = {
        expanded = icons.ui.Expanded,
        collapsed = icons.ui.Collapsed,
        current_frame = icons.ui.FoldClosed
    },
})

-- automatic open/close
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
