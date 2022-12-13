{ config, lib, pkgs, ... }:

{
  imports = [ ./global ];
  home = {
    username = "konrad";
    homeDirectory = "/Users/${config.home.username}";
  };
}

