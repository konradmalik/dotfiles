{ lib, modulesPath, ... }:
{
  imports = [
    ./nixos.nix
    # headless defaults: no docs, xdg icons/sounds/mime, udisks, default packages
    "${modulesPath}/profiles/minimal.nix"
  ];

  home-manager.users.konrad.imports = [ ../../home/profiles/server.nix ];

  konrad.services = {
    autoupgrade.enable = true;
    healthcheck.enable = lib.mkDefault true;
    syncthing = {
      enable = true;
      bidirectional = false;
    };
  };

  # servers mostly fetch from caches and build little, so build inputs aren't worth
  # their space; anything gc'd is fetched again on the next build
  nix.settings = {
    keep-derivations = false;
    keep-outputs = false;
  };

  # minimal.nix drops all docs, but man pages are worth their space
  documentation = {
    enable = true;
    man.enable = true;
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };
}
