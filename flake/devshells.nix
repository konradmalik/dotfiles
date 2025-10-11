{ inputs, ... }:
{
  perSystem =
    { pkgs, inputs', ... }:
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
                age
                git
                home-manager
                manix
                nmap
                sops
                ssh-to-age
              ])
              ++ pkgs.lib.optionals pkgs.stdenvNoCC.isDarwin darwinPackages
              ++ pkgs.lib.optionals pkgs.stdenvNoCC.isLinux [ inputs'.disko.packages.disko ];
          };
        };
    };
}
