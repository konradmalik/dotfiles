{ config, pkgs, lib, ... }:
let
  keys = config.sshKeys.personal;
in
{
  home.activation = {
    authorized_keys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -n "$VERBOSE_ARG" ]; then
          echo "will insert ${toString (builtins.length keys)} keys to authorized_keys'"
      fi
      $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.ssh
      $DRY_RUN_CMD chmod 700 ${config.home.homeDirectory}/.ssh
      $DRY_RUN_CMD rm -f ${config.home.homeDirectory}/.ssh/authorized_keys
      $DRY_RUN_CMD printf "# generated via home-manager\n${lib.concatStringsSep "\n" keys}" >> ${config.home.homeDirectory}/.ssh/authorized_keys
      $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.ssh/authorized_keys
    '';
  };
}
