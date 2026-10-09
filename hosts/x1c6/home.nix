{
  konrad.hyprland.monitors.enable = true;
  # on plug-in the daemon picks the best hardware match
  # ties going to the name sorting first
  konrad.hyprland.monitors.profiles =
    let
      laptop.key = "au optronics|0x233d";
      dell.key = "dell inc.|dell u3419w|9g2f6t2";
    in
    {
      laptop = [ laptop ];
      dell = [
        (laptop // { enabled = false; })
        dell
      ];
    };

  # only docked now and then, a stale snapshot there is expected
  konrad.programs.restic.repositories.local.maxSnapshotAgeDays = null;

  konrad.hardware.touchscreen.name = "raydium-corporation-raydium-touch-system";
}
