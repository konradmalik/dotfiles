# sourced on login shell. Once in linux, on every new terminal in macos

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
  export SESSION_TYPE=remote/ssh
else
  export SESSION_TYPE=local
fi

