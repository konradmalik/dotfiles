{ pkgs, ... }:

let
  # nixified plugins
  boole = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "boole";
    version = "2022-11-15";
    src = pkgs.fetchFromGitHub {
      owner = "nat-418";
      repo = "boole.nvim";
      rev = "d059fd7da634aaaabddbb280709f92effd9f2dba";
      sha256 = "sha256-86+hAli8l7Htzx3SgFqE4aOoMKceMAf2M1fzUcl262g=";
    };
    meta.homepage = "https://github.com/nat-418/boole.nvim";
  };
  nvim-luaref = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-luaref";
    version = "2022-01-17";
    src = pkgs.fetchFromGitHub {
      owner = "milisims";
      repo = "nvim-luaref";
      rev = "9cd3ed50d5752ffd56d88dd9e395ddd3dc2c7127";
      sha256 = "sha256-nmsKg1Ah67fhGzevTFMlncwLX9gN0JkR7Woi0T5On34=";
    };
    meta.homepage = "https://github.com/milisims/nvim-luaref";
  };
in
{
  home = {
    sessionVariables = {
      # The EDITOR editor should be able to work without use of "advanced"
      # terminal functionality (like old ed or ex mode of vi).
      # It was used on teletype terminals.
      EDITOR = "nvim -e -u NONE";
      VISUAL = "nvim -u NONE";
      GIT_EDITOR = "nvim -u NONE";
    };

    packages = with pkgs;[
      #makes sense to keep those globally
      nodePackages.prettier
      shfmt
    ];
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = false;
    withNodeJs = false;
    withRuby = false;
    extraPackages = [
      # this won't be useful globally, so neovim only is fine
      pkgs.shellcheck
    ];
    plugins = with pkgs.vimPlugins; [
      # dependencies
      plenary-nvim
      nui-nvim
      nvim-web-devicons
      # treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-context
      nvim-treesitter-textobjects
      # completion
      {
        plugin = nvim-cmp;
        optional = false;
      }
      {
        plugin = cmp-buffer;
        optional = false;
      }
      {
        plugin = cmp-nvim-lsp;
        optional = false;
      }
      {
        plugin = cmp-path;
        optional = false;
      }
      {
        plugin = cmp_luasnip;
        optional = false;
      }
      # lsp
      {
        plugin = nvim-lspconfig;
        optional = false;
      }
      {
        plugin = neodev-nvim;
        optional = false;
      }
      {
        plugin = null-ls-nvim;
        optional = false;
      }
      {
        plugin = luasnip;
        optional = false;
      }
      {
        plugin = friendly-snippets;
        optional = false;
      }
      {
        plugin = fidget-nvim;
        optional = false;
      }
      # dap
      {
        plugin = nvim-dap;
        optional = true;
      }
      {
        plugin = nvim-dap-ui;
        optional = true;
      }
      {
        plugin = nvim-dap-virtual-text;
        optional = true;
      }
      # telescope
      {
        plugin = telescope-nvim;
        optional = false;
      }
      {
        plugin = telescope-fzf-native-nvim;
        optional = false;
      }
      # statusline
      lualine-nvim
      nvim-navic
      # misc
      boole
      comment-nvim
      {
        plugin = diffview-nvim;
        optional = false;
      }
      gitsigns-nvim
      {
        plugin = harpoon;
        optional = false;
      }
      impatient-nvim
      indent-blankline-nvim
      nvim-luaref
      vim-sleuth
      which-key-nvim
      # ui
      catppuccin-nvim
      dressing-nvim
      {
        plugin = neo-tree-nvim;
        optional = false;
      }
    ];
  };

  xdg.configFile."nvim" = {
    source = "${pkgs.dotfiles}/neovim";
    recursive = true;
  };
}
