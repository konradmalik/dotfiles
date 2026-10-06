{
  default = {
    description = "Plain flake for full customization";
    path = ./default;
    welcomeText = ''
      # Plain flake initialized

      Next steps:
      - replace `pkgs.hello` in `flake.nix` with your project's tools
      - run `direnv allow` (or `nix develop`)
      - `nix fmt` to format, `nix flake check` to verify formatting
    '';
  };
}
