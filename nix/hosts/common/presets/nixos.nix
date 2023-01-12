{ config, pkgs, lib, inputs, outputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    ./../global/nix/nixos.nix
    ./../global/home-manager.nix
    ./../global/openssh.nix
    ./../global/tailscale.nix

    ./../users/konrad
  ] ++ (builtins.attrValues (import ./../modules));

  # make tmp in ram
  # boot.tmpOnTmpfs = true;
  # boot.tmpOnTmpfsSize = "25%";
  # clean tmp after reboot
  boot.cleanTmpDir = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  services.printing.enable = false;

  virtualisation.docker = {
    enable = true;
  };

  # shared sops config
  sops = {
    defaultSopsFile = ./../secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];
  environment.pathsToLink = [ "/share" "/bin" ];

  # for compatibility with nix-shell, nix-build, etc.
  environment.etc.nixpkgs.source = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];

  system.stateVersion = lib.mkDefault "22.11";
}
