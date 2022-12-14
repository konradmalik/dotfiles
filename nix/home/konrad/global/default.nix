{ config, lib, pkgs, dotfiles, ... }:

let
  asdf = pkgs.unstable.asdf-vm;
  # additional git packages
  gitPackages = with pkgs; [ delta git-extras ];
  # custom tmux plugins
  tmuxSuspend = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-suspend";
      version = "main";
      src = pkgs.fetchFromGitHub
        {
          owner = "MunifTanjim";
          repo = "tmux-suspend";
          rev = "f7d59c0482d949013851722bb7de53c0158936db";
          sha256 = "sha256-+1fKkwDmr5iqro0XeL8gkjOGGB/YHBD25NG+w3iW+0g=";
        };
    };
  tmuxModeIndicator = pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-mode-indicator";
      version = "main";
      src = pkgs.fetchFromGitHub
        {
          owner = "MunifTanjim";
          repo = "tmux-mode-indicator";
          rev = "11520829210a34dc9c7e5be9dead152eaf3a4423";
          sha256 = "sha256-hlhBKC6UzkpUrCanJehs2FxK5SoYBoiGiioXdx6trC4=";
        };
    };
in
{
  home = {
    packages = with pkgs;[
      moreutils
      unzip
      wget
      curl
      tree
      tldr
      bottom
      nq

      fzf
      bat
      ripgrep
      ripgrep-all
      fd
      sd
      sad

      hyperfine
      viddy
      watchexec

      jq
      jo
      jc
      dsq
      tidy-viewer

      du-dust
      zoxide
      procs
      exa

      up
      croc
      bitwarden-cli
      glow

      azure-cli
      awscli
    ] ++ [
      asdf
    ] ++ gitPackages;

    file.".gdbinit".source = "${dotfiles}/gdb/.gdbinit";
    file.".inputrc".source = "${dotfiles}/inputrc/.inputrc";
    file.".earthly/config.yml".source = "${dotfiles}/earthly/config.yml";
    file.".local/bin" = {
      source = "${dotfiles}/bin";
      recursive = true;
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # dotfiles
  xdg.configFile."glow/glow.yml".source = "${dotfiles}/glow/glow.yml";
  # k9s is installed on per project basis, but config can be global
  xdg.configFile."k9s/skin.yml".source = "${dotfiles}/k9s/skin.yml";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;
    enableScDaemon = false;
    grabKeyboardAndMouse = true;
    extraConfig = ''
      # timeout pinentry (s)
      pinentry-timeout 30
    '';
  };

  programs.git = {
    enable = true;
    package = pkgs.git;
    # extraConfig won't do anything here because I link the config file below.
    # I may transition fully to home-manager someday...
  };
  xdg.configFile."git/config".source = "${dotfiles}/git/config";

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    stdlib = ''
      # enable asdf support
      use_asdf() {
        source_env "$(${asdf}/bin/asdf direnv envrc "$@")"
      }
    '';
  };

  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    sensibleOnTop = false;
    extraConfig = lib.strings.concatStringsSep "\n" [
      (builtins.readFile "${dotfiles}/tmux/konrad.conf")
      (builtins.readFile "${dotfiles}/tmux/catppuccin.conf")
    ];
    plugins = [
      tmuxSuspend
      tmuxModeIndicator
    ];
  };

  programs.starship = {
    enable = true;
    # enable once we move zsh here
    enableZshIntegration = false;
    settings = {
      add_newline = false;
      command_timeout = 2000;

      aws.disabled = true;
      battery.disabled = true;
      cmd_duration. disabled = true;
      crystal.disabled = true;
      dart.disabled = true;
      docker_context. disabled = true;
      dotnet.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      env_var.disabled = true;
      erlang.disabled = true;
      gcloud.disabled = true;
      golang.disabled = false;
      line_break.disabled = false;
      java.disabled = false;
      julia.disabled = true;
      kubernetes.disabled = false;
      lua.disabled = false;
      memory_usage.disabled = true;
      nim.disabled = true;
      nix_shell.disabled = false;
      package.disabled = true;
      ocaml.disabled = true;
      openstack.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      purescript.disabled = true;
      python.disabled = false;
      ruby.disabled = true;
      rust.disabled = false;
      shlvl.disabled = true;
      singularity.disabled = true;
      swift.disabled = true;
      zig.disabled = true;
    };
  };
}

