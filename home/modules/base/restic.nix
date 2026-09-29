{ config, lib, ... }:
{
  # every machine with backups enabled keeps an offsite copy here, hosts only
  # set its includes
  config = lib.mkIf config.konrad.programs.restic.enable {
    konrad.programs.restic.repositories.b2 = {
      # backblaze through its s3-compatible api, because the native b2 backend
      # has known error handling issues
      repository = "s3:s3.eu-central-003.backblazeb2.com/backups-km";
      environment.AWS_ACCESS_KEY_ID = "0035814e69b653f0000000006";
      environmentFiles.AWS_SECRET_ACCESS_KEY = config.sops.secrets."restic/b2_application_key".path;
    };

    sops.secrets."restic/b2_application_key" = { };
  };
}
