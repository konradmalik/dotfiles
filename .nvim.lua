vim.lsp.config("nixd", {
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { config.allowUnfree = true; }",
            },
            options = {
                nixos = {
                    expr = "(builtins.getFlake ( toString ./.)).nixosConfigurations.framework.options",
                },
                home_manager = {
                    expr = "(builtins.getFlake (toString ./.)).nixosConfigurations.framework.options.home-manager.users.type.getSubOptions []",
                },
                darwin = {
                    expr = "(builtins.getFlake (toString ./.)).darwinConfigurations.m4.options",
                },
            },
        },
    },
})

-- qmlls comes from this repo's devShell, not from the neovim flake, and finds
-- both the quickshell modules and this checkout's own `qs.*` modules through
-- the QML_IMPORT_PATH the devShell exports.
vim.lsp.config("qmlls", {
    cmd = { "qmlls" },
    filetypes = { "qml" },
    root_markers = { ".qmlls.ini" },
})
vim.lsp.enable("qmlls")
