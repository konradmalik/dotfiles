return require('packer').startup(function()
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    -- Treesitter (syntax highlight)
    use { 
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    -- LSP and completion
    use { 'neovim/nvim-lspconfig' }
    use { 'nvim-lua/completion-nvim',
        requires = {'steelsojka/completion-buffers', opt = true},
    }

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {'kyazdani42/nvim-web-devicons', opt = true},
        },
    }

    -- statusline
    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }

    -- Fugitive for Git
    use { 'tpope/vim-fugitive' }

    -- theme
    use { 'joshdick/onedark.vim' }
end)
