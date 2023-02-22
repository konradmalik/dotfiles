require("konrad.dap.ui")
require("konrad.dap.virtual-text")
require("konrad.dap.keymaps")

local configs = {
    "cs",
    "go",
    "python",
}

for _, config in ipairs(configs) do
    local found, _ = pcall(require, "konrad.dap.configurations." .. config)
    if not found then
        vim.notify("could not find DAP config for " .. config)
    end
end
