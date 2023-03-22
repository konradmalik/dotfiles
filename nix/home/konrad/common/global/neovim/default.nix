{ config, pkgs, ... }:
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

  programs.git.ignores = [
    ".netcoredbg_hist"
    ".null-ls*"
    ".nvim.lua"
  ];

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
    plugins = pkgs.callPackage ./plugins.nix { };
  };

  xdg.configFile =
    {
      "nvim" = {
        source = "${pkgs.dotfiles}/neovim";
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
