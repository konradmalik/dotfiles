{ config, lib, ... }:

{
  imports = [ ./global ];
  home = {
    username = lib.mkDefault "konrad";
    homeDirectory = lib.mkDefault "/Users/${config.home.username}";
  };
}

