{ config, pkgs, lib, inputs, outputs, ... }:
let
  key = builtins.elemAt (builtins.filter (k: k.type == "ed25519") config.services.openssh.hostKeys) 0;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko

    ./../global/home-manager.nix
    ./../global/locale.nix
    ./../global/nix/nixos.nix
    ./../global/oom-killer.nix
    ./../global/openssh.nix
    ./../global/tailscale.nix

    ./../users/konrad
  ] ++ (builtins.attrValues (import ./../modules))
  ++ (builtins.attrValues outputs.nixosModules);

  # make tmp in ram
  # boot.tmpOnTmpfs = true;
  # boot.tmpOnTmpfsSize = "25%";
  # clean tmp after reboot
  boot.cleanTmpDir = true;

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      flags = [ "--all" ];
      dates = "weekly";
    };
  };

  # shared sops config
  sops = {
    defaultSopsFile = ./../secrets.yaml;
    age.sshKeyPaths = [ key.path ];
  };

  programs.zsh.enable = true;

  services.geoclue2.enable = lib.mkDefault true;

  environment = {
    systemPackages = [ pkgs.nixos-label ];
    pathsToLink = [ "/share" "/bin" ];
  };

  system.stateVersion = lib.mkDefault "22.11";
}
