{ config, pkgs, lib, inputs, outputs, ... }:
let
  key = builtins.elemAt (builtins.filter (k: k.type == "ed25519") config.services.openssh.hostKeys) 0;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    ./../global/home-manager.nix
    ./../global/locale.nix
    ./../global/nix/nixos.nix
    ./../global/oom-killer.nix
    ./../global/openssh.nix
    ./../global/tailscale.nix

    ./../users/konrad
  ] ++ (builtins.attrValues (import ./../modules));

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
    systemPackages = [ ];
    pathsToLink = [ "/share" "/bin" ];
  };

  system.stateVersion = lib.mkDefault "22.11";
}
