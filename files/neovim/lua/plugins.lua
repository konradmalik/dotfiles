return require('packer').startup(function()
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    -- Treesitter (syntax highlight)
    use { "nvim-treesitter/nvim-treesitter" }

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = {'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim'}
    }

    -- LSP and completion
    use { 'neovim/nvim-lspconfig' }
    use { 'nvim-lua/completion-nvim',
        requires = {'steelsojka/completion-buffers', opt = true},
    }

    -- Fugitive for Git
    use { 'tpope/vim-fugitive' }

    -- fast statusline
    use {
        "hoob3rt/lualine.nvim",
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    -- bufferline
    use {
        "jose-elias-alvarez/buftabline.nvim",
        requires = {"kyazdani42/nvim-web-devicons"}
    }

    -- theme
    use { 'joshdick/onedark.vim' }
end)
