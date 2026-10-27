{ config, ... }:
{
  programs.git.ignores = [ ".direnv" ];

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    config = {
      global = {
        strict_env = true;
        warn_timeout = "12h";
      };
      whitelist = {
        prefix = [ "${config.xdg.userDirs.projects}/github.com/konradmalik" ];
      };
    };
  };
}
