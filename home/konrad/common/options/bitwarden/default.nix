{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.konrad.programs.bitwarden;
  # exports secrets kept as hidden fields of a single item, see bw-env.sh
  bw-env = pkgs.callPackage ./bw-env { bitwarden-cli = cfg.package; };
  # the inverse, turns a .env file into such an item
  bw-env-import = pkgs.callPackage ./bw-env-import { bitwarden-cli = cfg.package; };
  # and back out again, for tools that insist on a .env file
  bw-env-export = pkgs.callPackage ./bw-env-export { bitwarden-cli = cfg.package; };
  # helper to unlock bw and export session automatically
  jq = "${pkgs.jq}/bin/jq";
  bw = "${cfg.package}/bin/bw";
  # this needs to be a shell function due to 'export'
  bwuFunc =
    # bash
    ''
      function bwu() {
        # declared separately, 'local x=$(...)' masks the exit status.
        # not named 'status', that one is read-only in zsh
        local bw_json vault_status session
        # not one pipeline, that would report jq's exit status instead of bw's
        bw_json=$(${bw} status) || return 1
        vault_status=$(${jq} -r .status <<<"$bw_json") || return 1
        case "$vault_status" in
        "unauthenticated")
            echo "Logging into Bitwarden" >&2
            session=$(${bw} login --raw) || return 1
            ;;
        "locked")
            echo "Unlocking Vault" >&2
            session=$(${bw} unlock --raw) || return 1
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
        ${bw} sync
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
    programs.zsh.initContent = bwuFunc;
    programs.bash.initExtra = bwuFunc;
    home.packages = [
      cfg.package
      bw-env
      bw-env-import
      bw-env-export
    ];
  };
}
