{ pkgs, ... }:
let
  plugins = {
    git = pkgs.yaziPlugins.git;
  };
in
{
  programs.yazi = {
    enable = true;

    plugins = {
      inherit (plugins) git;
    };

    initLua = ''
      require("git"):setup()
    '';

    settings = {
      mgr = {
        linemode = "size";
        show_symlink = true;
      };

      plugin = {
        prepend_fetchers = [
          {
            group = "git";
            url = "*/";
            run = "git";
          }
          {
            group = "git";
            url = "*";
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
