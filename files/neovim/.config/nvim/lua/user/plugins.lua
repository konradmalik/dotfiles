local fn = vim.fn

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local packer = require('packer')

return packer.startup(function(use)
    -- Packer can manage itself
    use {'wbthomason/packer.nvim'}

    -- Treesitter (syntax highlight)
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    -- LSP and completion
    use { 'neovim/nvim-lspconfig' } -- Collection of configurations for built-in LSP client
    use { "williamboman/nvim-lsp-installer" } -- simple to use language server installer
    use { 'nvim-lua/completion-nvim' }
    use {
        'hrsh7th/nvim-cmp', -- Autocompletion plugin
        requires = {
            'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
            'hrsh7th/cmp-buffer',   -- buffer source for nvim-cmp
            'hrsh7th/cmp-path',     -- path source for nvim-cmp
            'lukas-reineke/cmp-rg', -- ripgrep text source for nvim-cmp
        },
    }

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {'kyazdani42/nvim-web-devicons'},
            {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
        },
    }

    -- statusline
    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    -- Fugitive for Git
    use { 'tpope/vim-fugitive' }

    -- no ls lsp
    use {
        "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
        requires = {
            {'nvim-lua/plenary.nvim'},
        },
    }

    -- which key
    use {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            }
        end
    }

    -- Harpoon by ThePrimeagen
    use {
        'ThePrimeagen/harpoon',
        requires = {
            {'nvim-lua/plenary.nvim'},
        },
    }

    -- themes
    use { 'joshdick/onedark.vim' }
    use { 'gruvbox-community/gruvbox' }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        packer.sync()
    end
end)
