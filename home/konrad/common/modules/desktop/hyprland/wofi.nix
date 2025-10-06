{
  config,
  pkgs,
  ...
}:
{
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 350;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = config.colorscheme.variant == "dark";
    };
  };

  xdg.configFile."wofi-power-menu.toml".text =
    # toml
    ''
      [wofi]
        path = "${config.programs.wofi.package}/bin/wofi"
      [menu.hibernate]
        enabled = "false"

      [menu.logout]
        enabled = "false"
    '';
  home.packages = [ pkgs.wofi-power-menu ];
}
