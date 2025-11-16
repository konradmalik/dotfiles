{ ... }:
{
  imports = [
    ./shared
    ./shared/not-hm.nix
  ];
  nixpkgs.overlays = [
    # FIXME after https://github.com/NixOS/nixpkgs/issues/461406
    (final: prev: {
      inherit (final.stable) fish;
    })
  ];
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Hour = 2;
        Minute = 0;
      };
    };
    linux-builder = {
      # sudo ssh linux-builder
      enable = false;
      ephemeral = true;
    };
  };
}
