{ config, pkgs, inputs, ... }:
let
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) gtkThemeFromScheme;
in
rec {
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk =
    let
      gtkExtraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    in
    {
      enable = true;
      font = {
        name = config.konrad.fontProfiles.regular.family;
        size = config.konrad.fontProfiles.regular.size;
      };
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "${config.colorscheme.slug}";
        package = gtkThemeFromScheme { scheme = config.colorscheme; };
      };
      gtk3.extraConfig = gtkExtraConfig;
      gtk4.extraConfig = gtkExtraConfig;
    };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "${gtk.theme.name}";
      "Net/IconThemeName" = "${gtk.iconTheme.name}";
    };
  };
}
