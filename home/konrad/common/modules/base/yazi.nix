{ config, pkgs, ... }:
let
  mkYaziPluginGithub = x: pkgs.fetchFromGitHub x;

  plugins =
    let
      yazi-plugins = mkYaziPluginGithub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "b12a9ab085a8c2fe2b921e1547ee667b714185f9";
        hash = "sha256-LWN0riaUazQl3llTNNUMktG+7GLAHaG/IxNj1gFhDRE=";
      };
    in
    {
      git = "${yazi-plugins}/git.yazi";
      kanagawa = mkYaziPluginGithub {
        owner = "dangooddd";
        repo = "kanagawa.yazi";
        rev = "31167ed54c9cc935b2fa448d64d367b1e5a1105d";
        hash = "sha256-phwGd1i/n0mZH/7Ukf1FXwVgYRbXQEWlNRPCrmR5uNk=";
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
