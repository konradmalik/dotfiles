-- impatient needs to be the first
require("konrad.impatient")

require("konrad.globals")
require("konrad.disable_builtin")
require("konrad.options")
require("konrad.keymaps")

require("konrad.diagnostic")
require("konrad.gitsigns")
require("konrad.lsp")
require("konrad.cmp")
require("konrad.telescope")
require("konrad.neo-tree")
require("konrad.harpoon")
require("konrad.diffview")

vim.api.nvim_create_user_command("DapInit", function()
    vim.api.nvim_command('packadd nvim-dap')
    vim.api.nvim_command('packadd nvim-dap-ui')
    vim.api.nvim_command('packadd nvim-dap-virtual-text')
    require("konrad.dap")
end, {});
