{
  config,
  ...
}:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${config.home.sessionVariables.TERMINAL} -e";
      };
    };
  };
}
