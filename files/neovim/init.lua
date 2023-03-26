-- impatient needs to be the first
require("konrad.impatient")

require("konrad.globals")
require("konrad.options")
require("konrad.keymaps")

require("konrad.diagnostic")
require("konrad.gitsigns")
require("konrad.colorscheme")
require("konrad.heirline")
require("konrad.lsp")
require("konrad.autotrim")
require("konrad.cmp")
require("konrad.telescope")
require("konrad.neo-tree")
require("konrad.harpoon")
require("konrad.diffview")

-- lazy loading on demand
local utils = require("konrad.utils")
utils.make_enable_command(
    "DapEnable",
    { 'nvim-dap', 'nvim-dap-ui', 'nvim-dap-virtual-text' },
    function()
        require("konrad.dap")
    end,
    {
        desc = "Initialize Dap functionalities",
    }
)

utils.make_enable_command(
    "CopilotEnable",
    { "copilot.lua", "copilot-cmp" },
    function()
        require("konrad.cmp.copilot")
    end,
    {
        desc = "Initialize Copilot server and cmp source",
    })
