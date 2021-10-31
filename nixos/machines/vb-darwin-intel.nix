{ config, pkgs, currentSystem, ... }:

{
    imports = [
        ./vm-shared.nix
    ];

    # We expect to run the VM on hidpi machines.
    hardware.video.hidpi.enable = true;

}
