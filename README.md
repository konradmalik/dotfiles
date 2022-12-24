# Dotfiles

Nix ftw.

This flake uses a private repo as input. You may want to override it. There is a dummy one here in `./private`;
Use something like this:

```bash
--override-input dotfiles-private path:./private;
```

## layers and programs folders

`layers` are intended to be imported as needed, on separate machines like `m3800.nix`, while everything in `programs`
is imported automatically in `darwin.nix`, `nixos.nix` etc.
