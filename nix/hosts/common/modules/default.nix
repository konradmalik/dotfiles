{
  autoupgrade = import ./autoupgrade.nix;
  bluetooth = import ./bluetooth.nix;
  sound = import ./sound.nix;
  syncthing = import ./syncthing.nix;
  wireless = import ./wireless.nix;
}
