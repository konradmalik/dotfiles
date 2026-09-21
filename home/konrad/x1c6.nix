{
  imports = [ ./common/profiles/laptop.nix ];

  wayland.windowManager.hyprland = {
    # extraConfig = ''
    #   hl.on("hyprland.start", function() hl.dispatch(hl.dsp.dpms({ action = "off", monitor = "eDP-1" })) end)
    # '';
    settings = {
      # monitor = [ { output = "eDP-1"; disabled = true; } ];
    };
  };

  konrad.hardware.touchscreen.name = "raydium-corporation-raydium-touch-system";
}
