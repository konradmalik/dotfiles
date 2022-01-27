local fn = vim.fn

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

local packer = require("packer")

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
		},
	})

	-- LSP
	use({ "neovim/nvim-lspconfig" }) -- Collection of configurations for built-in LSP client
	use({ "williamboman/nvim-lsp-installer" }) -- simple to use language server installer
	--
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

	-- Fuzzy finder
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "kyazdani42/nvim-web-devicons" },
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
		},
	})
	use({ "nvim-telescope/telescope-file-browser.nvim" })

	-- misc plugins
	use({ "windwp/nvim-autopairs" }) -- pairing of " ( etc
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

	-- remote development (requires 'distant' binary)
	use({ "chipsenkbeil/distant.nvim" })

	-- remote containers (vscode based)
	use({ "jamestthompson3/nvim-remote-containers" })

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

	-- themes
	use({ "navarasu/onedark.nvim" })
	use({ "gruvbox-community/gruvbox" })
	use({ "dracula/vim" })

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		packer.sync()
	end
end)
