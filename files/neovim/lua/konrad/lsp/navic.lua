return function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        vim.cmd('packadd nvim-navic')
        require("nvim-navic").attach(client, bufnr)
    end
end
