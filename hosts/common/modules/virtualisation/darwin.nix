{ pkgs, ... }:
{
  environment.systemPackages = [
    # FIXME: fails to start with 'cannot find network plugin'
    # pkgs.container
  ];
}
