{
  specialArgs,
  inputs,
  self,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = pkgs.lib.optionalAttrs (pkgs.stdenvNoCC.isLinux) (
        let
          rpiSdCard = "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix";
          # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
          missingKernelModulesFix = {
            nixpkgs.overlays = [
              (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
            ];
          };
          modules = [
            rpiSdCard
            missingKernelModulesFix
          ];
        in
        {
          installer-iso = import ./../pkgs/special/installer-iso { inherit pkgs specialArgs; };
          rpi4-1-sd-image =
            (self.nixosConfigurations.rpi4-1.extendModules { inherit modules; }).config.system.build.sdImage;
          rpi4-2-sd-image =
            (self.nixosConfigurations.rpi4-2.extendModules { inherit modules; }).config.system.build.sdImage;
        }
      );
    };
}
