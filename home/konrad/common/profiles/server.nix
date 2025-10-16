{
  imports = [ ../systems/nixos.nix ];

  programs.atuin.settings.auto_sync = false;
  programs.nix-index.enable = false;
}
