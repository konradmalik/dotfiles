{
  osConfig ? { },
  pkgs,
  lib,
  inputs,
  ...
}:
let
  inherit (pkgs.stdenvNoCC.hostPlatform) system;

  llama = import ../../../../../hosts/common/modules/llama/shared.nix;

  servesLocally = osConfig.services.llama-swap.enable or false;

  baseURL = "http://${
    if servesLocally then "127.0.0.1" else llama.remoteHost
  }:${toString llama.port}/v1";

  llamaModels = llama.models;

  defaultModel =
    let
      flagged = lib.attrNames (lib.filterAttrs (_: model: model.default or false) llamaModels);
    in
    if lib.length flagged == 1 then
      lib.head flagged
    else
      throw "exactly one model in llama/models.nix must set default = true, got: ${toString flagged}";

  # opencode picks the *last* matching rule (Permission.evaluate uses findLast),
  # so every exception has to be emitted after the catch-all. Plain values are
  # unordered, hence the explicit dag entry.
  denyAfterCatchAll = lib.hm.dag.entryAfter [ "*" ] "deny";

  secretPaths = [
    "*.env"
    "*.env.*"
    "*.key"
    "*.pem"
    "*.p12"
    "*.pfx"
    "*/.aws/*"
    "*/.azure/*"
    "*/.config/gcloud/*"
    "*/.config/gh/hosts.yml"
    "*/.config/op/*"
    "*/.config/sops/*"
    "*/.docker/config.json"
    "*/.gnupg/*"
    "*/.netrc"
    "*/.password-store/*"
    "*/.pgpass"
    "*/.ssh/*"
    "*/credentials/*"
    "*/secrets/*"
    "*/.kube/config"
  ];
in
{
  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${system}.opencode;

    settings = {
      autoupdate = false;

      permission = {
        # generous on reading, except anything that smells like a credential
        read = {
          "*" = "allow";
        }
        // lib.genAttrs secretPaths (_: denyAfterCatchAll);

        glob = "allow";
        grep = "allow";
        list = "allow";
        lsp = "allow";
        todowrite = "allow";
        question = "allow";

        edit = "ask";

        # NOTE: deliberately no `cat *`/`git *` style allowlist. The bash tool
        # matches the whole command string, and `*` compiles to `.*`, so `cat *`
        # would also permit `cat x && rm -rf y`. Only exact patterns are safe,
        # and opencode's "always allow" button covers the repetition per session.
        bash = {
          "*" = "ask";
          "env" = denyAfterCatchAll;
          "env *" = denyAfterCatchAll;
          "printenv" = denyAfterCatchAll;
          "printenv *" = denyAfterCatchAll;
        };

        # anything reaching outside the project, or off the machine
        external_directory = "ask";
        webfetch = "ask";
        websearch = "ask";
      };

      provider.llama-swap = {
        npm = "@ai-sdk/openai-compatible";
        name = "llama-swap";
        options = {
          inherit baseURL;
          apiKey = "llama-swap";
        };
        models = lib.mapAttrs (_: model: {
          inherit (model) name;
          reasoning = true;
          tool_call = true;
          limit = {
            context = model.contextSize;
            output = 32768;
          };
        }) llamaModels;
      };

      model = "llama-swap/${defaultModel}";
    };
  };

  programs.git.ignores = [ ".opencode" ];
}
