{
  bitwarden = import ./bitwarden.nix;
  restic = import ./restic;
  ssh-egress = import ./ssh-egress.nix;
  ssh-keys = import ./ssh-keys.nix;
  syncthing = import ./syncthing.nix;
  tmux = import ./tmux;
}
