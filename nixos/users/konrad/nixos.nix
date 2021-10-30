{ pkgs, ... }:

{
  users.users.konrad = {
    isNormalUser = true;
    home = "/home/konrad";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
  };
}
