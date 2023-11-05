{ config, pkgs, lib, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      # uses terminal colors according to base16 spec
      theme = "base16";
    };
  };
}
