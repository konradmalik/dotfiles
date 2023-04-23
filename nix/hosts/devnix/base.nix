{ config, pkgs, lib, inputs, customArgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ./../common/global/docker.nix
    ./../common/global/home-manager.nix
    ./../common/global/locale.nix
    ./../common/global/nix/shared.nix
    ./../common/global/openssh.nix

    ./../common/users/konrad
  ];

  sops = {
    defaultSopsFile = ./../secrets.yaml;
    # age.sshKeyPaths = [ key.path ];
  };

  programs.zsh.enable = true;

  environment.pathsToLink = [ "/bin" "/lib" "/man" "/share" ];

  system.stateVersion = lib.mkDefault "22.11";

  networking.hostName = "devnix";
}
