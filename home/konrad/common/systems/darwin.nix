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
    ../modules/base
    ../modules/desktop/common/alacritty.nix
    ../modules/desktop/common/ghostty.nix
    ../modules/desktop/common/mpv.nix
  ];

  home = {
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

  konrad.programs.ssh-egress.hardwareKeys = [
    "${config.home.homeDirectory}/.ssh/id_ecdsa_sk_rk_ssh"
  ];

  programs.zsh = {
    shellAliases = {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };
    initContent = lib.optionalString osConfig.homebrew.enable ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
