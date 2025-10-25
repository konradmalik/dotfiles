{
  config,
  lib,
  pkgs,
  ...
}:
let
  zshInitContent = ''
    # beeping is annoying
    unsetopt beep

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
  '';

  zcompdumpRemoval = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD rm -f ${config.programs.zsh.dotDir}/.zcompdump
  '';

  zshCompletionInit = ''
    # autocompletion
    # (-C makes it regenerate .zcompdump only if it does not exist)
    # (I delete .zcompdump in a script after each system rebuild)
    autoload -Uz compinit && compinit -C
    # bash-compatible mode
    autoload -Uz bashcompinit && bashcompinit
    # Zsh can generate completion from looking at the output of --help
    compdef _gnu_generic -default- -P '*'
    # use cache
    zstyle ':completion:*' use-cache on
    zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/.zcompcache"

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
    # group completions
    zstyle ':completion:*' group-name '''
    # completions colors
    zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
    # show corrections
    zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
    # show 'tag' info
    zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'

    # carapace support
    export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  '';
in
{
  home.activation = {
    inherit zcompdumpRemoval;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "viins";
    shellAliases = {
      # For a full list of active aliases, run `alias`.
      # to run command that is shadowed by an alias run (for example): \ls or command ls
      cat = "bat";
      g = "git";
      grep = "grep --color=auto";
      ip = "ip --color";
      mv = "mv -i";
      rm = "rm -i";
      watch = "viddy";
      ".." = "cd ..";
      "..." = "cd ../..";
    }
    // pkgs.lib.optionalAttrs pkgs.stdenvNoCC.isLinux {
      pbcopy = "${pkgs.wl-clipboard}/bin/wl-copy";
      pbpaste = "${pkgs.wl-clipboard}/bin/wl-paste";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
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
    initContent = zshInitContent;
    completionInit = zshCompletionInit;
  };
}
