{ config, pkgs, ... }:
let
  mkYaziPluginGithub = x: pkgs.fetchFromGitHub x;

  plugins =
    let
      yazi-plugins = mkYaziPluginGithub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "beb586aed0d41e6fdec5bba7816337fdad905a33";
        hash = "sha256-enIt79UvQnKJalBtzSEdUkjNHjNJuKUWC4L6QFb3Ou4=";
      };
    in
    {
      git = "${yazi-plugins}/git.yazi";
      kanagawa = mkYaziPluginGithub {
        owner = "dangooddd";
        repo = "kanagawa.yazi";
        rev = "d98f0c3e27299f86ee080294df2722c5a634495a";
        hash = "sha256-Z/lyXNCSqX0wvCQd39ZedxOGlhRzQ+M0hqzkBEcpxEE=";
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
      manager = {
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
