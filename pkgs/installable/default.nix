{ pkgs }:
{
  rfv = pkgs.callPackage ./rfv { };
  realize-symlink = pkgs.callPackage ./realize-symlink { };
}
