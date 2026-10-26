{ pkgs, inputs }:
{
  fonts = import ./fonts { inherit pkgs inputs; };
  scripts = import ./scripts pkgs;
}
