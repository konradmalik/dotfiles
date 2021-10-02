return require('packer').startup(function()
    -- Packer can manage itself as an optional plugin
    use {'wbthomason/packer.nvim', opt = true}

    -- Treesitter (syntax highlight)
    use { 
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }

    -- LSP and completion
    use { 'neovim/nvim-lspconfig' } -- Collection of configurations for built-in LSP client
    use { 'nvim-lua/completion-nvim' } 
    use {
        'hrsh7th/nvim-cmp', -- Autocompletion plugin
        requires = {
            'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
            'hrsh7th/cmp-buffer',   -- buffer source for nvim-cmp
            'hrsh7th/cmp-path',     -- path source for nvim-cmp
        },
    }

    -- Fuzzy finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'},
            {'kyazdani42/nvim-web-devicons'},
        },
    }

    -- statusline
    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    -- Fugitive for Git
    use { 'tpope/vim-fugitive' }

    -- theme
    use { 'joshdick/onedark.vim' }
end)
