{ pkgs, customArgs, ... }:
{
  imports = [
    ./firefox.nix
    ./font.nix
    ./gnome-keyring.nix
    ./gtk.nix
    ./mpv.nix
    ./qt.nix
  ];

  xdg.mimeApps.enable = true;
  # silently override mimeapps
  xdg.configFile."mimeapps.list".force = true;

  home =
    # TODO remove after https://github.com/NixOS/nixpkgs/pull/305711 lands in nixos-unstable
    let
      mechanize = pkgs.python311Packages.mechanize.overridePythonAttrs (old: { doCheck = false; });
      calibre_fix = pkgs.calibre.override
        (old: {
          python3Packages = old.python3Packages // { inherit mechanize; };
        });
    in
    {
      packages = with pkgs; [
        bitwarden
        calibre_fix
        obsidian
        signal-desktop
        slack
        spotify
        tdesktop
        # for xdg-open in 'gx' in vim for example
        xdg-utils
        zathura
      ];
    };

  konrad.wallpaper = "${customArgs.files}/wallpapers/bishal-mishra.jpg";
}
