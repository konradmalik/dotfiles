{
  alacritty = import ./alacritty.nix;
  bitwarden = import ./bitwarden.nix;
  gpg-agent = import ./gpg-agent.nix;
  tmux = import ./tmux;
  restic = import ./restic.nix;
  ssh-egress = import ./ssh-egress.nix;
  syncthing = import ./syncthing.nix;
  wallpaper = import ./wallpaper.nix;
  wezterm = import ./wezterm.nix;
}
