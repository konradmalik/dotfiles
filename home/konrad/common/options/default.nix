{
  bitwarden = import ./bitwarden.nix;
  nvim = import ./nvim.nix;
  restic = import ./restic;
  ssh-egress = import ./ssh-egress.nix;
  ssh-keys = import ./ssh-keys.nix;
  tmux = import ./tmux;
}
