local status_ok, mason = pcall(require, "mason")
if not status_ok then
    vim.notify("mason cannot be initialized!")
    return
end

local uiicons = require("konrad.icons").ui

mason.setup({
    ui = {
        icons = {
            package_installed = uiicons.Check,
            package_pending = uiicons.History,
            package_uninstalled = uiicons.Close,
        }
    },
    -- this puts mason binaries to the end of PATH
    -- this is good, since we can prefer tools installed manually, asdf, python venv etc.
    -- only if a tool does not exist anywhere else in PATH, it will be used from Mason
    -- this also works for tools installed with mason-tool-installer since it relies on Mason
    PATH = "append",
})
