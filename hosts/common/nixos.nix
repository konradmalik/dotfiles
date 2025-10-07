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

    ./modules/docker/linux.nix
    ./modules/home-manager.nix
    ./modules/locale.nix
    ./modules/locate.nix
    ./modules/memory.nix
    ./modules/nix/nixos.nix
    ./modules/openssh.nix
    ./modules/stylix.nix
    ./modules/tailscale.nix

    ./users/konrad/nixos.nix
  ]
  ++ (builtins.attrValues (import ./options));

  boot = {
    # clean tmp after reboot
    tmp.cleanOnBoot = true;
    kernel.sysctl."fs.inotify.max_user_instances" = 524288;
  };

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [ pciutils ];
    pathsToLink = [
      "/bin"
      "/lib"
      "/man"
      "/share"
    ];
  };

  system = {
    stateVersion = lib.mkDefault "25.05";
  };
}
