{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    container
  ];
}
