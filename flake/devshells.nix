{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      devShells =
        let
          darwinPackages = builtins.attrValues (
            builtins.removeAttrs inputs.darwin.packages.${pkgs.system} [ "default" ]
          );
        in
        {
          default = pkgs.mkShell {
            NIX_CONFIG = "extra-experimental-features = nix-command flakes";

            name = "dotfiles";
            packages =
              (with pkgs; [
                manix
                nmap
                age
                git
                home-manager
                sops
                ssh-to-age
              ])
              ++ pkgs.lib.optionals pkgs.stdenvNoCC.isDarwin darwinPackages;
          };
        };
    };
}
