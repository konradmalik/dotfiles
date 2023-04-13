{ config, pkgs, outputs, ... }:
let
  nvimPkgs = pkgs.unstable;
in
{
  home = {
    sessionVariables = {
      # should be like that but many programs don't respect VISUAL in favor of EDITOR so...
      # EDITOR = "nvim -u NONE -e";
      EDITOR = "nvim -u NONE";
      # no profile makes it start faster than the speed of light
      VISUAL = "nvim -u NONE";
      GIT_EDITOR = "nvim -u NONE";
    };
  };

  programs.git.ignores = [
    ".netcoredbg_hist"
    ".null-ls*"
    ".nvim.lua"
  ];

  programs.neovim = {
    enable = true;
    package = nvimPkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = false;
    # copilot dependency
    withNodeJs = true;
    withRuby = false;
    # plugin dependencies
    extraPackages = with pkgs; [
      # telescope
      fzf
      ripgrep
      # null-ls
      nodePackages.prettier
      shfmt
      pkgs.shellcheck
    ];
    plugins = pkgs.callPackage ./plugins.nix { pkgs = nvimPkgs; };
  };

  xdg.configFile =
    {
      "nvim" = {
        source = "${outputs.lib.dotfiles}/neovim";
        recursive = true;
      };

      "nvim/lua/konrad/nix-colors.lua".text =
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
    };
}
