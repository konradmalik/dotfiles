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
                    expr = "(builtins.getFlake (toString ./.)).darwinConfigurations.mbp13.options",
                },
            },
        },
    },
})
