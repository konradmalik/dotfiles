{
  home.sessionVariables.BROWSER = "firefox";
  programs.firefox = {
    enable = true;
    profiles = {
      home = {
        id = 0;
      };
      work = {
        id = 1;
      };
    };
  };

  stylix.targets.firefox.profileNames = [
    "home"
    "work"
  ];
}
