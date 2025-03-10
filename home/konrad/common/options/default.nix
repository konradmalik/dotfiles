{
  alacritty = import ./alacritty;
  bitwarden = import ./bitwarden.nix;
  ghostty = import ./ghostty;
  fonts = import ./fonts.nix;
  monitors = import ./monitors.nix;
  restic = import ./restic;
  ssh-egress = import ./ssh-egress.nix;
  ssh-keys = import ./ssh-keys.nix;
  syncthing = import ./syncthing.nix;
  tmux = import ./tmux;
  wallpaper = import ./wallpaper.nix;
  wezterm = import ./wezterm;
}
