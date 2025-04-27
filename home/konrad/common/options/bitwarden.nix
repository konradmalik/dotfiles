{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.konrad.programs.bitwarden;
  # helper to unlock bw and export session automatically
  jq = "${pkgs.jq}/bin/jq";
  bw = "${cfg.package}/bin/bw";
  # this needs to be a shell function due to 'export'
  bwuFunc = ''
    function bwu() {
      BW_STATUS=$(${bw} status | ${jq} -r .status)
      case "$BW_STATUS" in
      "unauthenticated")
          echo "Logging into Bitwarden"
          export BW_SESSION=$(${bw} login --raw)
          ;;
      "locked")
          echo "Unlocking Vault"
          export BW_SESSION=$(${bw} unlock --raw)
          ;;
      "unlocked")
          echo "Vault is unlocked"
          ;;
      *)
          echo "Unknown Login Status: $BW_STATUS"
          return 1
          ;;
      esac
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
    home.packages = [ cfg.package ];
  };
}
