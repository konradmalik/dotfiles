{ config, pkgs, lib, ... }:
{
  home.activation = {
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
}
