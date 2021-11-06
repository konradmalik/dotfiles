![Ubuntu Focal](https://github.com/konradmalik/dotfiles/actions/workflows/focal.yaml/badge.svg)
![Arch Linux](https://github.com/konradmalik/dotfiles/actions/workflows/arch.yaml/badge.svg)

# Dotfiles

Works for:

- Archlinux (amd64)
- MacOS (amd64)
- Ubuntu
  - amd64
  - aarch64

ATTENTION: Installing wil override any existing and matching dotfiles in your home dir! Only proceed when you have proper backups or if you know what you are doing.

To use, clone on a new machine and proceed with README in ansible dir.

## Symlinking

I use GNU Stow. TL;DR:

```
# from the `dofiles/files` dir
$ stow --target="$HOME" zsh
# no-folding for dirs which should not be git-managed
$ stow --target="$HOME" --no-folding vscode-darwin
```

No fold those dirs:
- gpg
- ssh
- vscode-darwin/linux

