{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    # FIXME: fails to build on aarch64-darwin
    package = (
      if pkgs.stdenv.hostPlatform.isDarwin then
        (builtins.getFlake "github:NixOS/nixpkgs/89570f24e97e614aa34aa9ab1c927b6578a43775")
        .legacyPackages.${pkgs.system}.starship
      else
        pkgs.starship
    );
    settings = {
      add_newline = false;
      command_timeout = 2000;

      aws.disabled = true;
      azure.disabled = true;
      gcloud.disabled = true;

      battery.disabled = true;
      cmd_duration.disabled = true;

      kubernetes.disabled = false;

      shell = {
        disabled = false;
        zsh_indicator = "";
        bash_indicator = "bsh ";
        format = "[$indicator]($style)";
      };
      shlvl = {
        disabled = false;
        # start with 1
        # tmux adds another 1
        # 3 and more is suspicious
        threshold = 3;
      };
    };
  };
}
