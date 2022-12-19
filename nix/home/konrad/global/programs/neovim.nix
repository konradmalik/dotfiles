{ pkgs, dotfiles, ... }:

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
  neo-tree-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "neo-tree-nvim";
    version = "2022-12-17";
    src = pkgs.fetchFromGitHub {
      owner = "nvim-neo-tree";
      repo = "neo-tree.nvim";
      rev = "73a90f6a736b51168ed05d89ed8872f75b98471c";
      sha256 = "sha256-/WLOKFdngvHPgeJc7xGnWx8yUjr2KSnrbOgP3nzS+jY=";
    };
    meta.homepage = "https://github.com/nvim-neo-tree/neo-tree.nvim";
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
  luv-vimdocs = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "luv-vimdocs";
    version = "2022-05-08";
    src = pkgs.fetchFromGitHub {
      owner = "nanotee";
      repo = "luv-vimdocs";
      rev = "4b37ef2755906e7f8b9a066b718d502684b55274";
      sha256 = "sha256-4WOmEvxH0ECuiViLx1KdCtKq7p5cvlwCW9eV7J5Pblo=";
    };
    meta.homepage = "https://github.com/nanotee/luv-vimdocs";
  };

  neovim = pkgs.neovim.override {
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    configure = {
      packages = with pkgs.vimPlugins; {

        dependencies = {
          start = [
            plenary-nvim
            nui-nvim
            nvim-web-devicons
          ];
        };

        treesitter = {
          start = [
            nvim-treesitter.withAllGrammars
            nvim-treesitter-context
            nvim-treesitter-textobjects
          ];
        };

        completion = {
          start = [
            nvim-cmp
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            cmp_luasnip
            cmp-dap
          ];
        };

        lsp = {
          start = [
            nvim-lspconfig
            null-ls-nvim
            luasnip
            friendly-snippets
            fidget-nvim
          ];
        };

        dap = {
          opt = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
        };

        telescope = {
          start = [
            telescope-nvim
            telescope-fzf-native-nvim
          ];
        };

        statusline = {
          start = [
            lualine-nvim
            nvim-navic
          ];
        };

        misc = {
          start = [
            boole
            comment-nvim
            diffview-nvim
            gitsigns-nvim
            harpoon
            impatient-nvim
            indent-blankline-nvim
            nvim-luaref
            luv-vimdocs
            vim-fugitive
            vim-sleuth
            which-key-nvim
          ];
        };

        ui = {
          start = [
            catppuccin-nvim
            dressing-nvim
            neo-tree-nvim
            # go back to this once better/more stable
            # noice-nvim
          ];
        };
      };
    };
  };
in
{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
      DIFFPROG = "nvim -d";
    };

    packages = [
      neovim
      pkgs.nodePackages.prettier
      pkgs.shfmt
      pkgs.shellcheck
    ];
  };

  xdg.configFile."nvim" = {
    source = "${dotfiles}/neovim";
    recursive = true;
  };
}
