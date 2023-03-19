{ config, pkgs, lib, ... }:

let
  mini-base16 = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "mini.base16";
    version = "2023-02-09";
    src = pkgs.fetchFromGitHub {
      owner = "echasnovski";
      repo = "mini.base16";
      rev = "5d403d8d606adf0fb0e247f51552b490e488341e";
      sha256 = "sha256-nLSLM6feFvEyvZOGpCQE/xrI4ZEJtTGx7W6IhY6p57k=";
    };
    meta.homepage = "https://github.com/echasnovski/mini.base16";
  };
  local-highlight = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "local-highlight";
    version = "2023-03-19";
    src = pkgs.fetchFromGitHub {
      owner = "tzachar";
      repo = "local-highlight.nvim";
      rev = "846cca30d7aa54591fbfaa0e9dba81f50cd9d1ac";
      sha256 = "sha256-B0iRKZr0o9JDhcA2kA4eIoX+DliXM+2EVJz3aZ/1hpk=";
    };
    meta.homepage = "https://github.com/tzachar/local-highlight.nvim";
  };
  nvim-luaref = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-luaref";
    version = "2022-02-17";
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
      # no profile makes it start faster than the speed of light
      EDITOR = "nvim -u NONE";
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
    package = pkgs.unstable.neovim-unwrapped;
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
    plugins = with pkgs.unstable.vimPlugins; [
      # dependencies
      plenary-nvim
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
      boole-nvim
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
      local-highlight
      nvim-luaref
      vim-sleuth
      which-key-nvim
      # ui
      {
        plugin = catppuccin-nvim;
        optional = false;
      }
      {
        plugin = mini-base16;
        optional = true;
      }
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

  xdg.configFile."nvim/lua/konrad/nix-colors.lua".text =
    let
      c = config.colorscheme.colors;
    in
    ''
      return {
        slug = "${config.colorscheme.slug}",
        colors = {
          base00 = '#${c.base00}',
          base01 = '#${c.base01}',
          base02 = '#${c.base02}',
          base03 = '#${c.base03}',
          base04 = '#${c.base04}',
          base05 = '#${c.base05}',
          base06 = '#${c.base06}',
          base07 = '#${c.base07}',
          base08 = '#${c.base08}',
          base09 = '#${c.base09}',
          base0A = '#${c.base0A}',
          base0B = '#${c.base0B}',
          base0C = '#${c.base0C}',
          base0D = '#${c.base0D}',
          base0E = '#${c.base0E}',
          base0F = '#${c.base0F}',
        },
      }
    '';
}
