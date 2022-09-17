local virtual_text_ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
if not virtual_text_ok then
    vim.notify("cannot load nvim-dap-virtual-text")
    return
end

virtual_text.setup({
    enabled = true, -- enable this plugin (the default)
    enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
    filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
    all_frames = true, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
})
