{ pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  hardware.raspberry-pi."4".audio.enable = true;

  # still aplay -l -> "no soundcards found" :(
  # https://github.com/NixOS/nixpkgs/issues/123725#issuecomment-1328342974
}
