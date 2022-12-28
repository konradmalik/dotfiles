# Dotfiles

Nix ftw.

## commands

### NixOS:

Build and enable config locally:

```bash
sudo nixos-rebuild --flake "git+file:///home/konrad/Code/dotfiles#$(hostname)" switch
```

Build Install ISO for m3800:

```bash
nix build .#m3800iso
```

Builder and enable config on remote:

```bash
# TODO not tested
# home-manager may be problematic: https://discourse.nixos.org/t/home-manager-flake-not-respecting-build-host-during-nixos-rebuild/16787
HOSTNAME=m3800 nixos-rebuild --flake "git+file:///home/konrad/Code/dotfiles#$HOSTNAME" --target-host $HOSTNAME --build-host $HOSTNAME --use-remote-sudo switch
```

### nix-darwin:

Build and enable config locally:

```bash
darwin-rebuild switch --flake "git+file:///Users/konrad/Code/dotfiles#$(hostname)"
```

### linux (non-NixOS; home-manager):

Build and enable config locally:

```bash
home-manager switch --flake "git+file:///home/konrad/Code/dotfiles#$(whoami)@$(hostname)"
```

## presets and modules

- `presets` are ready to use templates `nixos.nix`, `darwin.nix` etc.
- `modules` are optional layers on top of presets, eg. `gui.nix`

An exemplary usage is:
`m3800.nix` defines a home-manager config for a m3800 machine.
First it imports `presets/nixos.nix` because it's a NixOS machine.
Then, it imports additional module `gui.nix` which adds personal GUI-related apps and configs
Finally, `m3800.nix` itself defines some machine specific configs like home directory, alacritty font size etc.
