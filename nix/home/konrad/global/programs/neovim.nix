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
      nvim-cmp
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      # lsp
      nvim-lspconfig
      null-ls-nvim
      luasnip
      friendly-snippets
      fidget-nvim
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
      telescope-nvim
      telescope-fzf-native-nvim
      # statusline
      lualine-nvim
      nvim-navic
      # misc
      boole
      comment-nvim
      diffview-nvim
      gitsigns-nvim
      harpoon
      impatient-nvim
      indent-blankline-nvim
      nvim-luaref
      luv-vimdocs
      vim-sleuth
      which-key-nvim
      # ui
      catppuccin-nvim
      dressing-nvim
      neo-tree-nvim
      # go back to this once better/more stable
      # noice-nvim
    ];
  };

  xdg.configFile."nvim" = {
    source = "${dotfiles}/neovim";
    recursive = true;
  };
}
