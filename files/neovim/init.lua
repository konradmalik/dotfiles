-- caching needs to be first
vim.loader.enable()

require("konrad.globals")
require("konrad.options")
require("konrad.folding")
require("konrad.keymaps")

require("konrad.diagnostic")
require("konrad.gitsigns")
require("konrad.colorscheme")
require("konrad.heirline")
require("konrad.lsp").setup()
require("konrad.autotrim")
require("konrad.cmp")
require("konrad.telescope")
require("konrad.neo-tree")
require("konrad.harpoon")
require("konrad.diffview")

-- lazy loading on demand
local utils = require("konrad.utils")
utils.make_enable_command(
    "CopilotEnable",
    { "copilot.lua", "copilot-cmp" },
    function()
        require("konrad.cmp.copilot")
    end,
    {
        desc = "Initialize Copilot server and cmp source",
    })

utils.make_enable_command(
    "DapEnable",
    { 'nvim-dap', 'nvim-dap-ui', 'nvim-dap-virtual-text' },
    function()
        require("konrad.dap").setup()
    end,
    {
        desc = "Initialize Dap functionalities",
    }
)

utils.make_enable_command(
    "UndotreeToggle",
    { "undotree" },
    function()
        vim.cmd("UndotreeToggle")
    end,
    {
        desc = "Initialize Undotree and open it",
    },
    -- no idea why if we delete UndotreeToggle before running packadd
    -- then the command from UndotreeToggle from undotree itself is also deleted...
    false)

utils.make_enable_command(
    "UndotreeToggle",
    { "undotree" },
    function()
        vim.cmd("UndotreeToggle")
    end,
    {
        desc = "Initialize Undotree and open it",
    },
    -- no idea why if we delete UndotreeToggle before running packadd
    -- then the command from UndotreeToggle from undotree itself is also deleted...
    false)

vim.api.nvim_create_autocmd('UiEnter', {
    callback = function() vim.cmd('packadd vim-fugitive') end,
    desc = "Lazily initialize vim-fugitive",
    once = true,
})
