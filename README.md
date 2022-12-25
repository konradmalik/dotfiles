# Dotfiles

Nix ftw.

This flake uses a private repo as input. You may want to override it. There is a dummy one here in `./private`;
Use something like this:

```bash
--override-input dotfiles-private path:./private;
```

This can be added to `nix build`, `nix flake check` and more.

## presets and modules

- `presets` are ready to use templates `nixos.nix`, `darwin.nix` etc.
- `modules` are optional layers on top of presets, eg. `gui.nix`

An exemplary usage is:
`m3800.nix` defines a home-manager config for a m3800 machine.
First it imports `presets/nixos.nix` because it's a NixOS machine.
Then, it imports additional module `gui.nix` which adds personal GUI-related apps and configs
Finally, `m3800.nix` itself defines some machine specific configs like home directory, alacritty font size etc.
