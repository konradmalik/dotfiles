{ config, ... }:
{
  programs.git.ignores = [
    ".direnv"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    stdlib = ''
      use_rtx() {
        direnv_load rtx direnv exec
      }
      use_asdf() {
        use_rtx
      }
    '';
    config = {
      global = {
        strict_env = true;
        warn_timeout = "12h";
      };
      whitelist = {
        prefix = [
          "${config.home.homeDirectory}/Code/github.com/konradmalik"
        ];
      };
    };
  };
}
