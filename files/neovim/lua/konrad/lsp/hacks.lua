---@param client table
local function omnisharp(client)
    -- disable codelens for omnisharp because it makes it extremely slow
    client.server_capabilities.codeLensProvider = nil

    ---TODO omnisharp does not implement semanticTokens properly
    ---https://github.com/OmniSharp/omnisharp-roslyn/issues/2483
    client.server_capabilities.semanticTokensProvider = nil
end

---A place for ugly workarounds for lsp servers
---@param client table
return function(client)
    if client.name == 'omnisharp' then
        omnisharp(client)
    end
end
