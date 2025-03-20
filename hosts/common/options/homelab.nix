{ lib, ... }:
let
  inherit (lib) mkOption types;
  homelabSubmodule = types.submodule {
    options = {
      localIP = mkOption {
        type = types.str;
        description = "Local IP address";
      };
    };
  };
in
{
  options.konrad.homelab = mkOption {
    type = types.attrsOf homelabSubmodule;
    default = { };
    description = "A structured attribute set of machine entries with their homelab details.";
  };
}
