{ pkgs, ... }:
{
  imports = [
    ./common
    ./ui
  ];

  home.packages = with pkgs; [ timeshift ];
}
