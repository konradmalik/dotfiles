{
  audio = import ./audio.nix;
  autoupgrade = import ./autoupgrade.nix;
  bluetooth = import ./bluetooth.nix;
  healthcheck = import ./healthcheck.nix;
  hd-idle = import ./hd-idle.nix;
  ntfy = import ./ntfy.nix;
  syncthing = import ./syncthing.nix;
  wireless = import ./wireless.nix;
}
