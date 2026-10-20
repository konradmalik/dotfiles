{ lib, pkgs, ... }:
let
  host = "gitlab.cerebredev.com";
  clientId = "8baf24f1017f63c505b6dc8d115fcab9bedc1c2eb9d63c1c3a3f91569cdd642c";
  registry = "registry.gitlab.cerebredev.com";

  # glab auth configure-docker would drop this next to the glab binary,
  # which is read-only here
  dockerCredentialGlab = pkgs.writeShellScriptBin "docker-credential-glab" ''
    exec ${lib.getExe pkgs.glab} auth docker-helper "$@"
  '';

  glabLogin = pkgs.writeShellApplication {
    name = "glab-login";
    runtimeInputs = [
      pkgs.glab
      pkgs.jq
    ];
    text = ''
      glab config set --host ${host} client_id ${clientId}
      glab auth status --hostname ${host} >/dev/null 2>&1 \
        || glab auth login --hostname ${host} --web --git-protocol ssh \
          --container-registry-domains ${registry}

      # docker reads credHelpers from here, podman falls back to this file too;
      # both write to it as well, so only merge the key in
      cfg="''${DOCKER_CONFIG:-$HOME/.docker}/config.json"
      mkdir -p "$(dirname "$cfg")"
      [[ -s "$cfg" ]] || echo '{}' >"$cfg"
      # rewrite in place to keep the file's permissions, it can hold other credentials
      merged="$(jq '.credHelpers["${registry}"] = "glab"' "$cfg")"
      echo "$merged" >"$cfg"
    '';
  };
in
{
  home.packages = [
    pkgs.glab
    dockerCredentialGlab
    glabLogin
  ];
}
