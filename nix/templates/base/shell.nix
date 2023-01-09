let
  flakeLock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsLock = flakeLock.nodes.nixpkgs.locked;
  lockedNixpkgs = import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${nixpkgsLock.rev}.tar.gz";
      sha256 = nixpkgsLock.narHash;
    })
    { };
in
{ pkgs ? lockedNixpkgs }:
with pkgs;
mkShell {
  name = "foo-shell";

  nativeBuildInputs = [
    # nix
    nil
    nixpkgs-fmt
  ];
}
