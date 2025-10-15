{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.stylix.nixosModules.stylix

    ../modules/docker/linux.nix
    ../modules/home-manager.nix
    ../modules/locale.nix
    ../modules/locate.nix
    ../modules/memory.nix
    ../modules/nix/nixos.nix
    ../modules/openssh.nix
    ../modules/stylix
    ../modules/tailscale.nix

    ../users/konrad/nixos.nix
  ]
  ++ (builtins.attrValues (import ../options));

  boot = {
    tmp.useTmpfs = true;
    kernel.sysctl."fs.inotify.max_user_instances" = 524288;
  };

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
  };

  environment.systemPackages = with pkgs; [ pciutils ];

  system.stateVersion = lib.mkDefault "25.05";
}
