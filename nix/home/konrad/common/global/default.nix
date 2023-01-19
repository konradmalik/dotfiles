{ config, pkgs, lib, inputs, outputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule

    ./bat.nix
    ./fzf.nix
    ./git.nix
    ./k9s.nix
    ./khal.nix
    ./neovim.nix
    ./ranger.nix
    ./shells.nix
    ./starship.nix
    ./tealdeer.nix
    ./tmux.nix
  ] ++ (builtins.attrValues (import ./../modules))
  ++ (builtins.attrValues outputs.homeManagerModules);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = lib.mkDefault "konrad";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.11";

    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      PAGER = "less -FirSwX";
      GOPATH = "${config.home.homeDirectory}/.go";
      GOBIN = "${config.home.homeDirectory}/.go/bin";
    };

    sessionPath = [
      "$GOBIN"
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
    ];

    packages = with pkgs;[
      curl
      moreutils
      nq
      psmisc
      tree
      unzip
      wget

      ripgrep
      ripgrep-all
      fd
      # fix for aarch64 is only on unstable as of now
      unstable.sad
      sd

      hyperfine
      viddy
      watchexec

      age
      dsq
      jq
      jo
      jc
      xsv

      du-dust
      duf
      procs

      croc
      glow
      up

      awscli
      azure-cli

      dive

      asdf-vm
      comma
    ];

    file.".gdbinit".source = "${pkgs.dotfiles}/gdb/.gdbinit";
    file.".inputrc".source = "${pkgs.dotfiles}/inputrc/.inputrc";
    file.".earthly/config.yml".source = "${pkgs.dotfiles}/earthly/config.yml";
    file.".local/bin" = {
      source = "${pkgs.dotfiles}/bin";
      recursive = true;
    };
    activation = {
      authorized_keys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -n "$VERBOSE_ARG" ]; then
            echo "path to copy from '${pkgs.dotfiles}/ssh/authorized_keys'"
        fi
        $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.ssh
        $DRY_RUN_CMD chmod 700 ${config.home.homeDirectory}/.ssh
        $DRY_RUN_CMD cp ${pkgs.dotfiles}/ssh/authorized_keys ${config.home.homeDirectory}/.ssh/authorized_keys
        $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.ssh/authorized_keys
      '';
    };
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # dotfiles
  xdg.configFile."glow/glow.yml".source = "${pkgs.dotfiles}/glow/glow.yml";

  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        temperature_type = "c";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    stdlib = ''
      # enable asdf support
      use_asdf() {
        source_env "$(${pkgs.asdf-vm}/bin/asdf direnv envrc "$@")"
      }
    '';
    config = {
      global = {
        strict_env = true;
        warn_timeout = "12h";
      };
      whitelist = {
        prefix = [
          "${config.home.homeDirectory}/Code/github.com/konradmalik"
        ];
      };
    };
  };

  programs.exa = {
    enable = true;
  };

  programs.gpg = {
    enable = true;
    # let's stick to old standards for now
    homedir = "${config.home.homeDirectory}/.gnupg";
  };

  programs.zoxide = {
    enable = true;
  };

  # colorscheme = lib.mkDefault colorSchemes.catppuccin;
  colorscheme = {
    slug = "catppuccin-macchiato";
    name = "Catppuccin Macchiato";
    author = "https://github.com/catppuccin/catppuccin";
    kind = "dark";
    colors = {
      base00 = "24273A"; # base
      base01 = "1E2030"; # mantle
      base02 = "363A4F"; # surface0
      base03 = "494D64"; # surface1
      base04 = "5B6078"; # surface2
      base05 = "CAD3F5"; # text
      base06 = "F4DBD6"; # rosewater
      base07 = "B7BDF8"; # lavender
      base08 = "ED8796"; # red
      base09 = "F5A97F"; # peach
      base0A = "EED49F"; # yellow
      base0B = "A6DA95"; # green
      base0C = "8BD5CA"; # teal
      base0D = "8AADF4"; # blue
      base0E = "C6A0F6"; # mauve
      base0F = "F0C6C6"; # flamingo
    };
  };
  konrad.wallpaper =
    let
      largest = f: xs: builtins.head (builtins.sort (a: b: a > b) (map f xs));
      largestWidth = largest (x: x.width) config.monitors;
      largestHeight = largest (x: x.height) config.monitors;
    in
    lib.mkDefault (nixWallpaperFromScheme
      {
        scheme = config.colorscheme;
        width = largestWidth;
        height = largestHeight;
        logoScale = 4;
      });
}
