# Dotfiles

Nix ftw.

This flake uses a private repo as input. You may want to override it. There is a dummy one here in `./private`;
Use something like this:
```bash
--override-input dotfiles-private path:./private;
```
