# syncthing settings shared by the nixos option and the darwin home-manager
# config: the given folders are shared with every other host
lib:
{
  hostName,
  type,
  folders,
}:
let
  devices = {
    framework.id = "S55JBIK-J5N2KHL-YFBB7A2-AQANZCQ-SEYILMM-OP6SZBB-6Y75A44-3PMY5AR";
    m4.id = "PHJIM6R-6CEM2HB-HNCTY4F-SFGWH5J-BBTNDB6-6AB3S7P-IXPCVDH-7LTZNAQ";
    rpi4-1.id = "HHMMUAO-2ADZE5M-DYXO5P5-AA7GE22-XCEWHMK-ZH2WAL3-ZWQFZ3N-ELJ5BA7";
    rpi4-2.id = "I5455AU-F2ZA6OT-O3KAIZS-7UGVDKA-OYF2T7P-RA556GI-FJKGNGN-ARXD5AP";
    x1c6.id = "44QKQXH-FWGCUJB-O4S36QZ-2LJ23DS-GXP5CAC-EIS75BN-EXRSY54-H5TAJAE";
  };
  otherDevices = lib.filterAttrs (n: _: n != hostName) devices;
in
assert lib.assertMsg (devices ? ${hostName}) "syncthing: ${hostName} is not in the devices list";
{
  devices = otherDevices;
  folders = lib.mapAttrs (_: path: {
    inherit path type;
    devices = lib.attrNames otherDevices;
  }) folders;
}
