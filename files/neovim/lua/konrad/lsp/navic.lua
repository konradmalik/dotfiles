return function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        vim.api.nvim_command('packadd nvim-navic')
        require("nvim-navic").attach(client, bufnr)
    end
end
