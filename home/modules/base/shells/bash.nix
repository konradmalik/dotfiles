{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    # history expansion (!!, !$) fills the prompt instead of running right away
    initExtra = "shopt -s histverify";
  };
}
