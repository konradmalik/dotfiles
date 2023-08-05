{ config, lib, pkgs, ... }:
let
  zshInitExtra = ''
    # beeping is annoying
    unsetopt beep
    # alacritty icon jumping
    # https://github.com/alacritty/alacritty/issues/2950#issuecomment-706610878
    printf "\e[?1042l"

    # enable directories stack
    setopt autopushd           # Push the current directory visited on the stack.
    setopt pushdignoredups    # Do not store duplicates in the stack.
    setopt pushdsilent         # Do not print the directory stack after pushd or popd.

    ## Reduce latency when pressing <Esc> (helps with vi mode)
    export KEYTIMEOUT=1

    # fix backspace issues according to https://superuser.com/questions/476532/how-can-i-make-zshs-vi-mode-behave-more-like-bashs-vi-mode/533685#533685
    bindkey "^?" backward-delete-char

    # Enable to edit command line in $VISUAL
    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey -M vicmd '^v' edit-command-line

    #### Functions
    weather() {
      local param="$1"
      if [ -z "$param" ]; then
          curl "wttr.in/?F"
      else
          curl "wttr.in/''${param}?F"
      fi
    }

    timezsh() {
      local shell=''${1-''$SHELL}
      for i in $(seq 1 10); do time $shell -i -c exit; done
    }

    flakify() {
      if [ ! -e flake.nix ]; then
        nix flake new -t github:konradmalik/dotfiles#default .
      fi
      direnv allow
    }

    # credit to https://github.com/MatthewCroughan/nixcfg
    flash-to() {
      if [ $(${pkgs.file}/bin/file $1 --mime-type -b) == "application/zstd" ]; then
        echo "Flashing zst using zstdcat | dd"
        ( set -x; ${pkgs.zstd}/bin/zstdcat $1 | sudo dd of=$2 status=progress iflag=fullblock oflag=direct conv=fsync,noerror bs=64k )
      elif [ $(${pkgs.file}/bin/file $2 --mime-type -b) == "application/xz" ]; then
        echo "Flashing xz using xzcat | dd"
        ( set -x; ${pkgs.xz}/bin/xzcat $1 | sudo dd of=$2 status=progress iflag=fullblock oflag=direct conv=fsync,noerror bs=64k )
      else
        echo "Flashing arbitrary file $1 to $2"
        sudo dd if=$1 of=$2 status=progress conv=sync,noerror bs=64k
      fi
    }

    # rfv keybind
    rfv-widget() { export VISUAL=nvim && ${pkgs.rfv}/bin/rfv }
    zle -N rfv-widget
    bindkey '^G' rfv-widget
  '';
  zshCompletionInit = ''
    # autocompletion
    autoload -Uz compinit && compinit
    # bash-compatible mode
    autoload -Uz bashcompinit && bashcompinit
    # Zsh can generate completion from looking at the output of --help
    compdef _gnu_generic -default- -P '*'
    # use cache
    zstyle ':completion::complete:*' use-cache 1
    # autocompletion menu
    zstyle ':completion:*' menu select
    # shift-tab to go back in completions
    bindkey '^[[Z' reverse-menu-complete
    # autocomplete with sudo
    zstyle ':completion::complete:*' gain-privileges 1
    # case insensitive and partial
    zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    # Defining the Completers
    zstyle ':completion:*' completer _extensions _complete _approximate
    # display completer while waiting
    zstyle ":completion:*" show-completer true
  '';
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [ "ignoredups" "ignorespace" ];
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.fzf = {
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.starship = {
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    dotDir = lib.removePrefix "${config.home.homeDirectory}" "${config.xdg.configHome}/zsh";
    defaultKeymap = "viins";
    profileExtra = ''
      # sourced on login shell, after zshenv.
      # Once in linux, on every new terminal in macos

      if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
        export SESSION_TYPE=remote/ssh
      else
        export SESSION_TYPE=local
      fi
    '';
    shellAliases = {
      # cat on steroids
      cat = "bat";
      # git (use for example g add instead of git add)
      g = "git";
      # colorize stuff
      grep = "grep --color=auto";
      ip = "ip --color";
      # safety measures
      mv = "mv -i";
      rm = "rm -i";
      # modern watch
      watch = "viddy";
      # For a full list of active aliases, run `alias`.
      # to run command that is shadowed by an alias run (for example): \ls or command ls
      # prime
      txs = "${pkgs.tmux-sessionizer}/bin/tmux-sessionizer";
      txw = "${pkgs.tmux-windowizer}/bin/tmux-windowizer";
      txr = "${pkgs.tmux-switcher}/bin/tmux-switcher";
      # faster navigation
      ".." = "cd ..";
      "..." = "cd ../..";
    };
    history = {
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      expireDuplicatesFirst = true;
      extended = false;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      save = 100000;
      size = 100000;
    };
    initExtra = zshInitExtra;
    completionInit = zshCompletionInit;
  };
}
