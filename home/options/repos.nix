{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.repos;
  projectsDir = config.xdg.userDirs.projects;
  repoModule =
    { config, ... }:
    {
      options = {
        url = mkOption {
          type = types.str;
          example = "https://github.com/konradmalik/dotfiles";
          description = "https clone url, works without credentials so a fresh machine can fetch it.";
        };

        path = mkOption {
          type = types.str;
          # host/user/repo under the projects dir, mirroring the url
          default = "${projectsDir}/${removePrefix "https://" config.url}";
          defaultText = literalExpression ''"''${config.xdg.userDirs.projects}/<host>/<user>/<repo>"'';
          description = "Where the repo is checked out.";
        };
      };
    };
in
{
  options.konrad.repos = mkOption {
    type = types.attrsOf (types.submodule repoModule);
    default = { };
    description = ''
      Repos this config refers to by path. Each one is cloned on activation if
      its path is missing, an existing checkout is never touched.
    '';
  };

  config.home.activation.cloneRepos = hm.dag.entryAfter [ "writeBoundary" ] (
    concatMapStrings (repo: ''
      if [[ ! -e ${escapeShellArg repo.path} ]]; then
        run ${getExe pkgs.git} clone ${escapeShellArg repo.url} ${escapeShellArg repo.path} \
          || warnEcho "could not clone ${repo.url}, will retry on next activation"
      fi
    '') (attrValues cfg)
  );
}
