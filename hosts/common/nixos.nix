{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  key = builtins.elemAt (builtins.filter (k: k.type == "ed25519") config.services.openssh.hostKeys) 0;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko

    ./modules/docker/linux.nix
    ./modules/home-manager.nix
    ./modules/locale.nix
    ./modules/locate.nix
    ./modules/memory.nix
    ./modules/nix/nixos.nix
    ./modules/openssh.nix
    ./modules/tailscale.nix

    ./users/konrad/nixos.nix

    # TODO: remove once fixed in .NET
    # https://github.com/NixOS/nixpkgs/issues/315574
    ./hack.nix
  ] ++ (builtins.attrValues (import ./options));

  boot = {
    # clean tmp after reboot
    tmp.cleanOnBoot = true;
    kernel.sysctl."fs.inotify.max_user_instances" = 524288;
  };

  # shared sops config
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ key.path ];
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

  system.stateVersion = lib.mkDefault "25.05";
}
