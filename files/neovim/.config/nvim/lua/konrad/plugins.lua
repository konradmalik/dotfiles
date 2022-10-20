-- Auto install packer.nvim if not exists
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
        install_path })
end

local status_ok, packer = pcall(require, "packer")
if not status_ok then
    vim.notify("cannot load packer")
    return
end

local has = function(x)
    return vim.fn.has(x) == 1
end

local is_wsl = (function()
    local output = vim.fn.systemlist "uname -r"
    return not not string.find(output[1] or "", "WSL")
end)()

local is_mac = has "macunix"
local is_linux = not is_wsl and not is_mac

local max_jobs = nil
if is_mac then
    max_jobs = 16
end

return packer.startup({
    function(use)

        local local_use = function(first, second, opts)
            opts = opts or {}

            local plug_path, home
            if second == nil then
                plug_path = first
                home = "konradmalik"
            else
                plug_path = second
                home = first
            end

            local local_path = "~/Code/plugins/" .. plug_path
            if vim.fn.isdirectory(vim.fn.expand(local_path)) == 1 then
                opts[1] = local_path
            else
                local remote_path = string.format("%s/%s", home, plug_path)
                opts[1] = remote_path
            end

            use(opts)
        end

        -- Packer can manage itself
        use({ "wbthomason/packer.nvim" })

        -- Treesitter (syntax highlight)
        use({
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate",
        })
        use({
            'nvim-treesitter/nvim-treesitter-context',
            requires = {
                "nvim-treesitter/nvim-treesitter",
            }
        })
        use({
            'nvim-treesitter/playground',
            -- run = ":TSInstall query",
            requires = {
                "nvim-treesitter/nvim-treesitter",
            }
        })

        -- completion
        use({
            "hrsh7th/nvim-cmp", -- Autocompletion plugin
            requires = {
                "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
                "hrsh7th/cmp-buffer", -- buffer source for nvim-cmp
                "hrsh7th/cmp-path", -- path source for nvim-cmp
                "hrsh7th/cmp-nvim-lua", -- lua source for nvim api
                "rcarriga/cmp-dap", -- DAP repl source for nvim-cmp
            },
        })

        -- LSP
        use({ "neovim/nvim-lspconfig" }) -- Collection of configurations for built-in LSP client
        -- simple to use language server installer
        use({
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        })
        -- no ls lsp server for formatters and linters
        use({
            "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
            requires = {
                {
                    "nvim-lua/plenary.nvim",
                },
            },
        })
        -- use mason to install any tools (like DAP)
        use({
            'WhoIsSethDaniel/mason-tool-installer.nvim',
            requires = {
                "mason.nvim",
            }
        })
        -- a nice widget to display lsp progress
        use({ "j-hui/fidget.nvim" })
        -- snippets
        use({ "L3MON4D3/LuaSnip" }) --snippet engine
        use({ "rafamadriz/friendly-snippets" }) -- a bunch of snippets to use

        -- DAP
        use({ 'mfussenegger/nvim-dap' })
        use({ "rcarriga/nvim-dap-ui",
            requires = { "mfussenegger/nvim-dap" }
        })
        use({ 'theHamsta/nvim-dap-virtual-text',
            requires = {
                "mfussenegger/nvim-dap",
                "nvim-treesitter/nvim-treesitter",
            }
        })

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
        use { 'nvim-telescope/telescope-ui-select.nvim' }
        use {
            "nvim-telescope/telescope-frecency.nvim",
            requires = { "tami5/sqlite.lua" }
        }

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
        use {
            'nvim-lualine/lualine.nvim',
            requires = { 'kyazdani42/nvim-web-devicons', opt = true }
        }
        use({
            "SmiteshP/nvim-navic",
            requires = "neovim/nvim-lspconfig"
        })

        -- Fugitive for Git
        use({ "tpope/vim-fugitive" })

        --- diffview
        use ({ 'sindrets/diffview.nvim',
            requires = {
                { 'nvim-lua/plenary.nvim' },
                { 'kyazdani42/nvim-web-devicons', opt = true }
            }
        })

        -- Harpoon by ThePrimeagen
        use({
            "ThePrimeagen/harpoon",
            requires = { "nvim-lua/plenary.nvim" },
        })

        -- which key
        use({ "folke/which-key.nvim" })

        -- lua caching to speed up the load time
        use({ 'lewis6991/impatient.nvim' })

        -- colorschemes
        use({ "catppuccin/nvim", as = "catppuccin" })

        -- lua docs inside neovim's help
        use({ "milisims/nvim-luaref" })
        use({ "nanotee/luv-vimdocs" })

        -- Automatically set up your configuration after cloning packer.nvim
        -- Put this at the end after all plugins
        if PACKER_BOOTSTRAP then
            packer.sync()
        end

    end,
    config = {
        max_jobs = max_jobs,
    },
})
