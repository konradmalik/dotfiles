{ config, pkgs, ... }:
let
  mkYaziPlugin =
    name:
    let
      pkg = mkYaziPluginGithub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "02d18be03812415097e83c6a912924560e4cec6d";
        hash = "sha256-1FZ8wcf2VVp6ZWY27vm1dUU1KAL32WwoYbNA/8RUAog=";
      };
    in
    "${pkg}/${name}.yazi";
  mkYaziPluginGithub =
    x:
    pkgs.stdenvNoCC.mkDerivation {
      name = x.repo;
      dontBuild = true;
      installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
      '';
      src = pkgs.fetchFromGitHub {
        inherit (x)
          owner
          repo
          rev
          hash
          ;
      };
    };

  plugins = {
    git = mkYaziPlugin "git";
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
        show_hidden = true;
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
