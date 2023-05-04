---A place for ugly workarounds for lsp servers
---@param client table
return function(client)
    local found, hack = pcall(require, "konrad.lsp.after_attach_hacks." .. client.name)
    if found then
        hack(client)
    end
end
