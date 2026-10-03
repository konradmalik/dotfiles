{ config, lib, ... }:
let
  inherit (config.sops) secrets;
in
{
  # Hosts only set includes
  config = lib.mkIf config.konrad.programs.restic.enable {
    konrad.programs.restic = {
      passwordFile = secrets."restic/password".path;
      ntfy = {
        tokenFile = secrets."ntfy/token".path;
        topicFile = secrets."ntfy/topic".path;
      };

      repositories.b2 = {
        # backblaze through its s3-compatible api, because the native b2 backend
        # has known error handling issues
        repository = "s3:s3.eu-central-003.backblazeb2.com/backups-km";
        environment.AWS_ACCESS_KEY_ID = "0035814e69b653f0000000006";
        environmentFiles.AWS_SECRET_ACCESS_KEY = secrets."restic/b2_application_key".path;
      };
    };

    sops.secrets =
      let
        # shared with the system-level ntfy service
        sopsFile = ../../../secrets/system.yaml;
      in
      {
        "restic/password" = { };
        "restic/b2_application_key" = { };
        "ntfy/token" = { inherit sopsFile; };
        "ntfy/topic" = { inherit sopsFile; };
      };
  };
}
