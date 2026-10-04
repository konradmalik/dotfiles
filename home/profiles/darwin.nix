{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  # apple's middleware, the only way to reach secure enclave backed keys
  skProvider = "/usr/lib/ssh-keychain.dylib";
in
{
  imports = [
    ./workstation.nix
  ];

  home = {
    homeDirectory = "/Users/${config.home.username}";

    packages = with pkgs; [
      # make linux people at home
      coreutils
      # make sure we use gnu versions of common commands
      findutils
      gawk
      gnugrep
      gnused
    ];

    sessionVariables = {
      XDG_RUNTIME_DIR = "$TMPDIR";
      # ssh-add and ssh-keygen don't read ssh_config, they need this instead
      SSH_SK_PROVIDER = skProvider;
    };
  };

  programs.ssh.settings."*".SecurityKeyProvider = skProvider;

  konrad.programs.ssh-egress.hardwareKeys = [ "${config.home.homeDirectory}/.ssh/hardware" ];

  konrad.obsidianPath = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents";

  konrad.programs.restic.repositories.b2.includes = [ "${config.home.homeDirectory}/Desktop" ];

  # the system option is nixos-only, here it runs as a launchd agent
  services.syncthing = {
    enable = true;
    settings = import ../../system/options/syncthing/settings.nix lib {
      inherit (osConfig.networking) hostName;
      type = "sendreceive";
      folders = {
        Documents = "${config.home.homeDirectory}/Documents";
        obsidian = config.konrad.obsidianPath;
      };
    };
  };

  programs.zsh = {
    shellAliases = {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };
    initContent = lib.optionalString osConfig.homebrew.enable ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
