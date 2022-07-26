local status_ok, mason = pcall(require, "mason")
if not status_ok then
    vim.notify("mason cannot be initialized!")
    return
end

local uiicons = require("user.icons").ui

mason.setup({
    ui = {
        icons = {
            package_installed = uiicons.Check,
            package_pending = uiicons.History,
            package_uninstalled = uiicons.Close,
        }
    }
})
