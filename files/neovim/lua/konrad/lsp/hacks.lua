---@param client table
local function omnisharp(client)
    -- disable codelens for omnisharp because it makes it extremely slow
    client.server_capabilities.codeLensProvider = nil

    ---TODO ugly workaround because omnisharp does not implement semanticTokens properly
    ---https://github.com/OmniSharp/omnisharp-roslyn/issues/2483
    ---needs to be called after Attach as those tokens come from the server itself
    local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
    local replace = function(tab, i, v)
        local nv = v:gsub('-', ' ')
        tab[i] = nv:gsub("%s+", '_')
    end

    for i, v in ipairs(tokenModifiers) do
        replace(tokenModifiers, i, v)
    end

    local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
    for i, v in ipairs(tokenTypes) do
        replace(tokenTypes, i, v)
    end
end

---A place for ugly workarounds for lsp servers
---@param client table
return function(client)
    if client.name == 'omnisharp' then
        omnisharp(client)
    end
end
