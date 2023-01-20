{ pkgs, lib, ... }:
{
  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        temperature_type = "c";
      };
    };
  };

}
