{ config, pkgs, lib, inputs, outputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.sops-nix.homeManagerModules.sops

    ./bat.nix
    ./bottom.nix
    ./earthly.nix
    ./fzf.nix
    ./git.nix
    ./glow.nix
    ./k9s.nix
    ./khal.nix
    ./neovim.nix
    ./packages.nix
    ./ranger.nix
    ./readline.nix
    ./shells.nix
    ./ssh-ingress.nix
    ./ssh-keys.nix
    ./starship.nix
    ./tealdeer.nix
    ./tmux.nix
  ] ++ (builtins.attrValues (import ./../modules))
  ++ (builtins.attrValues outputs.homeManagerModules);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = lib.mkDefault "konrad";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.11";

    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      PAGER = "less -FirSwX";
      GOPATH = "${config.home.homeDirectory}/.go";
      GOBIN = "${config.home.homeDirectory}/.go/bin";
    };

    sessionPath = [
      "$GOBIN"
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
    ];
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # shared sops config
  sops = {
    defaultSopsFile = ./../secrets.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/personal.txt";
  };

  # colorscheme = lib.mkDefault colorSchemes.catppuccin;
  colorscheme = {
    slug = "catppuccin-macchiato";
    name = "Catppuccin Macchiato";
    author = "https://github.com/catppuccin/catppuccin";
    kind = "dark";
    colors = {
      base00 = "24273A"; # base
      base01 = "1E2030"; # mantle
      base02 = "363A4F"; # surface0
      base03 = "494D64"; # surface1
      base04 = "5B6078"; # surface2
      base05 = "CAD3F5"; # text
      base06 = "F4DBD6"; # rosewater
      base07 = "B7BDF8"; # lavender
      base08 = "ED8796"; # red
      base09 = "F5A97F"; # peach
      base0A = "EED49F"; # yellow
      base0B = "A6DA95"; # green
      base0C = "8BD5CA"; # teal
      base0D = "8AADF4"; # blue
      base0E = "C6A0F6"; # mauve
      base0F = "F0C6C6"; # flamingo
    };
  };
  konrad.wallpaper =
    let
      largest = f: xs: builtins.head (builtins.sort (a: b: a > b) (map f xs));
      largestWidth = largest (x: x.width) config.monitors;
      largestHeight = largest (x: x.height) config.monitors;
    in
    lib.mkDefault (nixWallpaperFromScheme
      {
        scheme = config.colorscheme;
        width = largestWidth;
        height = largestHeight;
        logoScale = 4;
      });
}
