{ config, lib, pkgs, dotfiles, ... }:
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

    # tmux baby
    bindkey -s '^F' '^utmux-sessionizer^M'

    ## Reduce latency when pressing <Esc>
    export KEYTIMEOUT=1

    # force vi mode for zle (zsh line editor)
    # (already done via viins)
    # bindkey -v

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

    # fix for tmux ssh socket
    fix_ssh_auth_sock() {
        # (On) reverses globbing order
        # https://unix.stackexchange.com/a/27400
        for tsock in /tmp/ssh*/agent*(On); do
            if [ -O "$tsock" ]; then
                sock=$tsock
                break
            fi
        done
        if [ -n "$sock" ]; then
            export SSH_AUTH_SOCK="$sock"
            echo "New socket: $sock"
        else
            echo "Could not find appropriate socket :("
            unset SSH_AUTH_SOCK
        fi
    }

    # update nix
    nix-update() {
        if [ "$(uname)" = "Darwin" ]; then
            darwin-rebuild switch --flake "git+file:///Users/konrad/Code/dotfiles#$(whoami)@$(hostname)"
        elif [ "$(uname)" = "Linux" ]; then
            # current user's home (flakes enabled)
            home-manager switch --flake "git+file:///home/konrad/Code/dotfiles#$(whoami)@$(hostname)"
            # system-wide
            sudo --login sh -c 'nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert; systemctl daemon-reload; systemctl restart nix-daemon'
        fi
    }

    # clean nix
    nix-clean() {
        if [ "$(uname)" = "Linux" ]; then
            # home
            home-manager expire-generations '-14 days'
        fi
        # current user's profile (flakes enabled)
        nix profile wipe-history --older-than 14d
        # nix store garbage collection
        nix store gc
        # system-wide (goes into users as well)
        sudo --login sh -c 'nix-collect-garbage --delete-older-than 14d'
    }
  '';
  zshCompletionInit = ''
    autoload -U compinit && compinit
    # autocompletion
    autoload -Uz compinit && compinit
    # bash-compatible mode
    autoload -Uz bashcompinit && bashcompinit
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

    # we need that as long as we use asdf and want autocompletion for those tools
    # lazy load zsh completion
    completers=(
        kubectl "kubectl completion zsh"
        helm "helm completion zsh"
        k3d "k3d completion zsh"
        kind "kind completion zsh"
        flux "flux completion zsh"
        tilt "tilt completion zsh"
        poetry "poetry completions zsh"
    )
    for ((i=1; i<''${#completers[@]}; i+=2)); do
        local cmd="''${completers[i]}"
        local completer="''${completers[i+1]}"

        eval "
            function _lazycomplete_$cmd {
                if command -v $cmd &>/dev/null; then
                    unfunction _lazycomplete_$cmd
                    # if a dedicated completions file is already handled by package manager
                    # do nothing
                    if [ ! -f $ZSH_VENDOR_COMPLETIONS/_$cmd ]; then
                        compdef -d $cmd
                        source <($completer)
                        # find the completion function we just sourced, some names are non-deterministic
                        local ccmd=\$(print -l \''${(ok)functions[(I)_*]} | grep \"$cmd\" | grep --invert-match \"^__\" | grep --invert-match \"debug\" | head -n 1)
                        # just in case, some generator commands expect to pass this manually, like tilt
                        # and some generate the command badly, like poetry. This is a mess
                        compdef \$ccmd $cmd
                        \$ccmd \"\$@\"
                    else
                        # it is already provided by package manager
                    fi
                fi
            }
            compdef _lazycomplete_$cmd $cmd
        "
    done
  '';
in
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
  };
  programs.exa.enableAliases = true;

  programs.fzf = {
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.starship = {
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    dotDir = ".config/zsh";
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
    shellGlobalAliases = {
      # asdf itself is managed via nix
      asdf-update = "asdf plugin-update --all";
      # cat on steroids
      cat = "bat";
      # colorize stuff
      grep = "grep --color=auto";
      ip = "ip --color";
      # safety measures
      rm = "rm -i";
      mv = "mv -i";
      # modern watch
      watch = "viddy";
    };
    shellAliases = {
      # For a full list of active aliases, run `alias`.
      # to run command that is shadowed by an alias run (for example): \ls or command ls
      # prime
      txs = "tmux-sessionizer";
      txw = "tmux-windowizer";
      # faster navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      # git (use for example g add instead of git add)
      g = "git";
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
    # use initExtraFirst for overrides in other modules
  };
}
