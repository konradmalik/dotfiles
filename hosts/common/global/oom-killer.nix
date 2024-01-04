{
  systemd.oomd = {
    enable = true;
    # fedora's defaults
    enableRootSlice = true;
    enableSystemSlice = false;
    enableUserServices = true;
  };
}
