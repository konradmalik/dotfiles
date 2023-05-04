local lsp = require("konrad.lsp.lsp")
local navic = require("konrad.lsp.navic")
local hacks = require("konrad.lsp.after_attach_hacks")

---@param client table
---@param bufnr number
local on_attach = function(client, bufnr)
    -- print("attaching lsp client " .. client.name .. " to buf " .. bufnr)
    -- builtin lsp
    lsp.attach(client, bufnr)
    -- navigation bar
    navic(client, bufnr)
end

---@param client table
---@param bufnr number
local on_detach = function(client, bufnr)
    -- print("detaching lsp client " .. client.name .. " from buf " .. bufnr)
    -- builtin lsp
    lsp.detach(client, bufnr)
    -- no way to detach navic as of now
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('personal-lsp-attach', { clear = true }),
    callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local bufnr = args.buf
        -- run needed hacks per server
        hacks(client)
        on_attach(client, bufnr)
    end,
})

vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('personal-lsp-detach', { clear = true }),
    callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local bufnr = args.buf
        on_detach(client, bufnr)
    end,
})
