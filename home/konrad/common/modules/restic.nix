{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.konrad.programs.restic;
in
{
  options.konrad.programs.restic = {
    enable = mkEnableOption "Enables restic backups through home-manager and backblaze b2";

    b2ApplicationId = mkOption {
      type = types.str;
      example = "12345";
      description = "backblaze account id";
      default = "0035814e69b653f0000000006";
    };

    b2ApplicationKeySopsRef = mkOption {
      type = types.str;
      example = "restic/b2_application_key";
      default = "restic/b2_application_key";
      description = "sops nix reference containing backblaze account key";
    };

    b2Bucket = mkOption {
      type = types.str;
      example = "somebucket";
      description = "b2 bucket to use for the restic repo";
      default = "backups-km";
    };

    passwordFileSopsRef = mkOption {
      type = types.str;
      description = "sops nix reference containing restic password";
      example = "restic/password";
      default = "restic/password";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.restic;
      description = "Package for restic";
      example = "pkgs.restic";
    };
  };

  config =
    let
      repostiory = "b2:${cfg.b2Bucket}";
      # wraps restic with backblaze env with all configs in one place
      b2ApplicationKeyFile = config.sops.secrets.${cfg.b2ApplicationKeySopsRef}.path;
      passwordFile = config.sops.secrets.${cfg.passwordFileSopsRef}.path;
      restic-b2 = pkgs.writeShellScriptBin "restic-b2"
        ''
          export B2_ACCOUNT_ID="${cfg.b2ApplicationId}"
          export B2_ACCOUNT_KEY="''$(<${b2ApplicationKeyFile})"

          export RESTIC_REPOSITORY="${repostiory}"
          export RESTIC_PASSWORD_FILE="${passwordFile}"

          export KEEP_LAST=3
          export RETENTION_HOURS=12
          export RETENTION_DAYS=7
          export RETENTION_WEEKS=4
          export RETENTION_MONTHS=12
          export RETENTION_YEARS=2

          ${cfg.package}/bin/restic "''$@"
        '';
    in
    mkIf cfg.enable {
      sops.secrets = {
        ${cfg.b2ApplicationKeySopsRef} = {
          path = "${config.xdg.dataHome}/restic/envs/b2/application_key";
        };
        ${cfg.passwordFileSopsRef} = {
          path = "${config.xdg.dataHome}/restic/password";
        };
      };

      home = {
        packages = [ restic-b2 ];
      };
    };
}
