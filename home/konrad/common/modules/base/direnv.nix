{ config, inputs,... }:
{
  imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

  programs.git.ignores = [ ".direnv" ];

  programs.direnv-instant ={
    enable = true;
    settings = {
      mux_delay = 5;
      debug_log = "/tmp/direnv-instant.log";
    };
  };

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
        prefix = [ "${config.home.homeDirectory}/Code/github.com/konradmalik" ];
      };
    };
  };
}
