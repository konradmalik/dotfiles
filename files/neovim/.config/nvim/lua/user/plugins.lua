-- Auto install packer.nvim if not exists
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

local status_ok, packer = pcall(require, "packer")
if not status_ok then
    vim.notify("cannot load packer")
    return
end

return packer.startup(function(use)
    -- Packer can manage itself
    use({ "wbthomason/packer.nvim" })

    -- Treesitter (syntax highlight)
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    })

    -- completion
    use({
        "hrsh7th/nvim-cmp", -- Autocompletion plugin
        requires = {
            "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
            "hrsh7th/cmp-buffer", -- buffer source for nvim-cmp
            "hrsh7th/cmp-path", -- path source for nvim-cmp
            "hrsh7th/cmp-nvim-lua", -- lua source for nvim api
        },
    })

    -- LSP
    use({ "neovim/nvim-lspconfig" }) -- Collection of configurations for built-in LSP client
    use({ "williamboman/nvim-lsp-installer" }) -- simple to use language server installer
    -- no ls lsp server for formatters and linters
    use({
        "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
        requires = {
            { "nvim-lua/plenary.nvim" },
        },
    })
    -- snippets
    use({ "L3MON4D3/LuaSnip" }) --snippet engine
    use({ "rafamadriz/friendly-snippets" }) -- a bunch of snippets to use
    -- highlighting same words
    use({ "RRethy/vim-illuminate" })

    -- Fuzzy finder and much more
    use({
        "nvim-telescope/telescope.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "kyazdani42/nvim-web-devicons" },
            { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
        },
    })
    use({ "nvim-telescope/telescope-file-browser.nvim" })

    -- search tool
    use({
        "nvim-pack/nvim-spectre",
        requires = {
            "nvim-lua/plenary.nvim",
        },
    })

    -- misc plugins
    use({ "numToStr/Comment.nvim" })
    use({
        "lewis6991/gitsigns.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
        },
    })
    use({
        "kyazdani42/nvim-tree.lua",
        requires = {
            "kyazdani42/nvim-web-devicons", -- optional, for file icon
        },
    })

    -- statusline
    use({
        "hoob3rt/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons" },
    })
    use({
        "SmiteshP/nvim-navic",
        requires = "neovim/nvim-lspconfig"
    })

    -- Fugitive for Git
    use({ "tpope/vim-fugitive" })

    -- Harpoon by ThePrimeagen
    use({
        "ThePrimeagen/harpoon",
        requires = {
            { "nvim-lua/plenary.nvim" },
        },
    })

    -- which key
    use({ "folke/which-key.nvim" })

    -- lua caching to speed up the load time
    use({ 'lewis6991/impatient.nvim' })

    -- themes
    use({ "navarasu/onedark.nvim" })
    use({ "gruvbox-community/gruvbox" })
    use({ "dracula/vim" })

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        packer.sync()
    end
end)
