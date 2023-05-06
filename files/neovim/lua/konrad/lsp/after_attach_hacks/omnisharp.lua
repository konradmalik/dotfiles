---@param client table
return function(client)
    -- disable codelens for omnisharp because it makes it extremely slow
    client.server_capabilities.codeLensProvider = nil

    -- omnisharp does not implement semanticTokens properly
    -- https://github.com/OmniSharp/omnisharp-roslyn/issues/2483
    client.server_capabilities.semanticTokensProvider = nil
end
