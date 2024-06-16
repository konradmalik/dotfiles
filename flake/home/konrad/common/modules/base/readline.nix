{
  programs.readline = {
    enable = true;
    includeSystemConfig = true;
    extraConfig = ''
      # vi mode everywhere
      set editing-mode vi
      set show-mode-in-prompt on

      # Show tab-completion options on first <tab> instead of waiting
      # for multiple completions.
      set show-all-if-ambiguous on

      # Case insensitive tab-completion
      set completion-ignore-case on
    '';
  };
}
