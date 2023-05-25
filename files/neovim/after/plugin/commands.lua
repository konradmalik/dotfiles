vim.api.nvim_create_user_command('CacheReset', function() vim.loader.reset() end, { desc = "Reset vim.loader cache", })
