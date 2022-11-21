# sourced on login shell, after zshenv.
# Once in linux, on every new terminal in macos

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
  export SESSION_TYPE=remote/ssh
else
  export SESSION_TYPE=local
fi

if [ -d $HOME/.nix-profile/etc/profile.d ]; then
  for i in $HOME/.nix-profile/etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
fi
