-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp

local function nix_omnisharp_dll_path()
    local binpath = vim.fn.exepath("OmniSharp")
    local omnipath = binpath:sub(1, -(string.len("bin/OmniSharp") + 1))
    local dllpath = omnipath .. "lib/omnisharp-roslyn/OmniSharp.dll"
    return dllpath
end

return {
    -- use dotnet in the current PATH, and use dll found from OmniSharp in the current path
    cmd = { "dotnet", nix_omnisharp_dll_path() },

    -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = true,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = true,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = true,
}
