{
  autoupgrade = import ./autoupgrade.nix;
  bluetooth = import ./bluetooth.nix;
  dhcp = import ./dhcp.nix;
  offdisp = import ./offdisp.nix;
  rtcwake = import ./rtcwake.nix;
  sound = import ./sound.nix;
  syncthing = import ./syncthing.nix;
  wireless = import ./wireless.nix;
}
