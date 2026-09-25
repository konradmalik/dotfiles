{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.konrad.programs.bitwarden;
  # moves secrets between hidden fields of an item and the environment,
  # see bw-env.sh for the get/import/export commands
  bw-env = pkgs.callPackage ./bw-env { bitwarden-cli = cfg.package; };
  # bwbio is bw with touchID unlock support, installed via homebrew (see hosts darwin.nix)
  bwbioAliases = optionalAttrs pkgs.stdenv.hostPlatform.isDarwin { bw = "bwbio"; };
  # bitwarden's ssh agent cannot be chained behind the tpm one, an unreachable -A
  # socket is fatal there. so it is scoped to a single command rather than exported,
  # which keeps the hardware key reachable for everything else in the session
  bwSshSock =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "${config.home.homeDirectory}/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
    else
      "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  bwsshFunc =
    # bash
    ''
      function bwssh() {
        # without a command the assignment below is not a prefix but a plain one,
        # which would leak into the shell instead of lasting for one command
        if [ "$#" -eq 0 ]; then
          echo "usage: bwssh <command> [args...]" >&2
          return 2
        fi
        # the socket file outlives the app that made it, so ask the agent instead:
        # 2 is "could not contact", 1 only means it is up and holding nothing
        SSH_AUTH_SOCK="${bwSshSock}" ssh-add -l >/dev/null 2>&1
        if [ "$?" -eq 2 ]; then
          echo "bwssh: cannot reach the bitwarden agent, is the desktop app running?" >&2
          return 1
        fi
        SSH_AUTH_SOCK="${bwSshSock}" "$@"
      }
    '';
  # helper to unlock bw and export session automatically
  jq = "${pkgs.jq}/bin/jq";
  # this needs to be a shell function due to 'export'
  bwuFunc =
    # bash
    ''
      function bwu() {
        # declared separately, 'local x=$(...)' masks the exit status.
        # not named 'status', that one is read-only in zsh
        local bw_json vault_status session
        # not one pipeline, that would report jq's exit status instead of bw's
        bw_json=$(bw status) || return 1
        vault_status=$(${jq} -r .status <<<"$bw_json") || return 1
        case "$vault_status" in
        "unauthenticated")
            echo "Logging into Bitwarden" >&2
            session=$(bw login --raw) || return 1
            ;;
        "locked")
            echo "Unlocking Vault" >&2
            session=$(bw unlock --raw) || return 1
            ;;
        "unlocked")
            echo "Vault is unlocked" >&2
            ;;
        *)
            echo "Unknown Login Status: $vault_status" >&2
            return 1
            ;;
        esac
        [ -z "$session" ] || export BW_SESSION="$session"
        bw sync
      }
    '';
in
{
  options.konrad.programs.bitwarden = {
    enable = mkEnableOption "Enables bitwarden cli client through home-manager";
    package = mkOption {
      type = types.package;
      default = pkgs.bitwarden-cli;
      description = "Package for cli";
      example = "pkgs.bitwarden-cli";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      initContent = bwuFunc + bwsshFunc;
      shellAliases = bwbioAliases;
    };
    programs.bash = {
      initExtra = bwuFunc + bwsshFunc;
      shellAliases = bwbioAliases;
    };
    home.packages = [
      cfg.package
      bw-env
    ];
  };
}
