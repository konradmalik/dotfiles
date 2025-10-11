{ ... }:
{
  imports = [
    ./shared
    ./shared/not-hm.nix
  ];
  nixpkgs.overlays = [
    # TODO https://github.com/NixOS/nixpkgs/pull/450512
    (final: prev: {
      inherit
        ((builtins.getFlake "github:NixOS/nixpkgs/9d4e5e1dc0ac64c9927ea8a256c4502a1e5541f0")
          .legacyPackages.${prev.system}
        )
        defaultGemConfig
        ;
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
