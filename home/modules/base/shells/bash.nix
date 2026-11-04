{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    # history expansion (!!, !$) expands in place when pressing space
    initExtra = "bind Space:magic-space";
  };
}
