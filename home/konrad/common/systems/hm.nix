{ inputs, ... }:
{
  imports = [
    ../modules/base
    ../../../../hosts/common/modules/nix/hm.nix

    inputs.stylix.homeModules.stylix
    ../../../../hosts/common/modules/stylix
  ];

  home.file.".face".source = ../../../../files/avatar.png;
}
