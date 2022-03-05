# Dotfiles

ATTENTION: Installing wil override any existing and matching dotfiles in your home dir! Only proceed when you have proper backups or if you know what you are doing.

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
