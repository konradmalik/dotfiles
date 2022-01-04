local status_ok, distant = pcall(require, "distant")
if not status_ok then
    vim.notify('distant cannot be initialized!')
    return
end

distant.setup {
    -- Applies Chip's personal settings to every machine you connect to
    --
    -- 1. Ensures that distant servers terminate with no connections
    -- 2. Provides navigation bindings for remote directories
    -- 3. Provides keybinding to jump into a remote file's parent directory
    ['*'] = require('distant.settings').chip_default()
}
