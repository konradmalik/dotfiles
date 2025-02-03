{ pkgs }:
{
  rfv = pkgs.callPackage ./rfv { };
  realize-symlink = pkgs.callPackage ./realize-symlink { };
  terminal-testdrive = pkgs.callPackage ./terminal-testdrive { };
  uniq-exts = pkgs.callPackage ./uniq-exts { };
}
