{ config, pkgs, lib, inputs, customArgs, ... }:
let
  key = builtins.elemAt (builtins.filter (k: k.type == "ed25519") config.services.openssh.hostKeys) 0;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko

    ./../global/docker/linux.nix
    ./../global/home-manager.nix
    ./../global/locale.nix
    ./../global/locate.nix
    ./../global/nix/nixos.nix
    ./../global/oom-killer.nix
    ./../global/openssh.nix
    ./../global/tailscale.nix

    ./../users/konrad/nixos.nix
  ] ++ (builtins.attrValues (import ./../modules))
  ++ (builtins.attrValues customArgs.nixosModules);

  # clean tmp after reboot
  boot.tmp.cleanOnBoot = true;

  # shared sops config
  sops = {
    defaultSopsFile = ./../secrets.yaml;
    age.sshKeyPaths = [ key.path ];
  };

  services.fwupd.enable = true;

  environment = {
    systemPackages = with pkgs;[
      pciutils
    ];
    pathsToLink = [ "/bin" "/lib" "/man" "/share" ];
  };

  system.stateVersion = lib.mkDefault "24.05";
}
