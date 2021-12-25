-- https://github.com/python-lsp/python-lsp-server
return {
    init_options = { provideFormatter = true },
    settings = {
        pylsp = {
            plugins = {
                pylsp_mypy = {
                    enabled = true,
                    live_mode = true,
                    dmypy = false,
                },
                pylsp_black = {
                    enabled = true,
                },
                pyls_isort = {
                    enabled = true
                },
            }
        }
    }
}
