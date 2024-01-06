{
  systemd.oomd = {
    enable = true;
    # fedora's defaults
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };
}
