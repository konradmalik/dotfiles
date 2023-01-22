{ config, pkgs, lib, modulesPath, inputs, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./../../hosts/common/global/nix/nixos.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "nix-installer-iso";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  users.users.root = {
    openssh.authorizedKeys.keys =
      let
        authorizedKeysFile = builtins.readFile "${pkgs.dotfiles}/ssh/authorized_keys";
        authorizedKeysFileLines = lib.splitString "\n" authorizedKeysFile;
        onlyKeys = lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) authorizedKeysFileLines;
      in
      onlyKeys;
  };

  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    ports = [ 22 ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = config.services.openssh.ports;
  };
}
