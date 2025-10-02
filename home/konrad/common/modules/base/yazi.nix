{ config, pkgs, ... }:
let
  mkYaziPluginGithub = x: pkgs.fetchFromGitHub x;

  plugins = {
    git = pkgs.yaziPlugins.git;
    kanagawa = mkYaziPluginGithub {
      owner = "dangooddd";
      repo = "kanagawa.yazi";
      rev = "a0b1d9dec31387b5f8a82c96044e6419b6c46534";
      hash = "sha256-nGFiAgVWfq7RkuGGCt07zm3z7ZTGiIPIR319ojPfdUk=";
    };
  };
in
{
  programs.yazi = {
    enable = true;

    flavors = {
      inherit (plugins) kanagawa;
    };

    plugins = {
      inherit (plugins) git;
    };

    initLua = ''
      require("git"):setup()
    '';

    theme = {
      flavor =
        let
          name = builtins.elemAt (pkgs.lib.splitString "-" config.colorscheme.slug) 0;
        in
        {
          dark = name;
          light = name;
        };
    };

    settings = {
      mgr = {
        linemode = "size";
        show_symlink = true;
      };

      plugin = {
        prepend_fetchers = [
          {
            id = "git";
            name = "*/";
            run = "git";
          }
          {
            id = "git";
            name = "*";
            run = "git";
          }
        ];
      };
    };
  };

  # https://yazi-rs.github.io/docs/installation/
  home.packages =
    with pkgs;
    [
      file
      ffmpeg
      p7zip
      jq
      poppler
      fd
      ripgrep
      fzf
      imagemagick
      zoxide
    ]
    ++ lib.optionals stdenvNoCC.isLinux [
      wl-clipboard
    ];
}
