{ config, pkgs, ... }: {
  # packages installed in system profile
  environment.systemPackages = [ ];

  networking.hostName = "mbp13";

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
  services.nix-daemon.enable = true;

  programs = { };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  users.users.konrad = {
    name = "konrad";
    home = "/Users/konrad";
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
