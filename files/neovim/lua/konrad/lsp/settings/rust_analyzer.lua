return {
    settings = {
        ["rust-analyzer"] = {
            files = {
                excludeDirs = {
                    "./.direnv/",
                    "./.git/",
                    "./.github/",
                    "./.gitlab/",
                    "./node_modules/",
                    "./ci/",
                    "./docs/",
                },
            },
            checkOnSave = {
                enable = true,
            },
            diagnostics = {
                enable = true,
                experimental = {
                    enable = true,
                }
            }
        }
    }
}
