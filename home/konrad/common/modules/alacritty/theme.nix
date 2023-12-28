{ colorscheme }:
''
  # Base16 ${colorscheme.slug} - alacritty color config

  [[colors.indexed_colors]]
  color = "#${colorscheme.colors.base09}"
  index = 16

  [[colors.indexed_colors]]
  color = "#${colorscheme.colors.base06}"
  index = 17

  [colors.bright]
  black = "#${colorscheme.colors.base04}"
  blue = "#${colorscheme.colors.base0D}"
  cyan = "#${colorscheme.colors.base0C}"
  green = "#${colorscheme.colors.base0B}"
  magenta = "#${colorscheme.colors.base0F}"
  red = "#${colorscheme.colors.base08}"
  white = "#${colorscheme.colors.base05}"
  yellow = "#${colorscheme.colors.base0A}"

  [colors.cursor]
  cursor = "#${colorscheme.colors.base06}"
  text = "#${colorscheme.colors.base00}"

  [colors.vi_mode_cursor]
  cursor = "#${colorscheme.colors.base07}"
  text = "#${colorscheme.colors.base00}"

  [colors.dim]
  black = "#${colorscheme.colors.base03}"
  blue = "#${colorscheme.colors.base0D}"
  cyan = "#${colorscheme.colors.base0C}"
  green = "#${colorscheme.colors.base0B}"
  magenta = "#${colorscheme.colors.base0F}"
  red = "#${colorscheme.colors.base08}"
  white = "#${colorscheme.colors.base05}"
  yellow = "#${colorscheme.colors.base0A}"

  [colors.hints.end]
  background = "#${colorscheme.colors.base04}"
  foreground = "#${colorscheme.colors.base00}"

  [colors.hints.start]
  background = "#${colorscheme.colors.base0A}"
  foreground = "#${colorscheme.colors.base00}"

  [colors.normal]
  black = "#${colorscheme.colors.base03}"
  blue = "#${colorscheme.colors.base0D}"
  cyan = "#${colorscheme.colors.base0C}"
  green = "#${colorscheme.colors.base0B}"
  magenta = "#${colorscheme.colors.base0F}"
  red = "#${colorscheme.colors.base08}"
  white = "#${colorscheme.colors.base05}"
  yellow = "#${colorscheme.colors.base0A}"

  [colors.primary]
  background = "#${colorscheme.colors.base00}"
  bright_foreground = "#${colorscheme.colors.base05}"
  dim_foreground = "#${colorscheme.colors.base05}"
  foreground = "#${colorscheme.colors.base05}"

  [colors.search.focused_match]
  background = "#${colorscheme.colors.base0B}"
  foreground = "#${colorscheme.colors.base00}"

  [colors.footer_bar]
  background = "#${colorscheme.colors.base04}"
  foreground = "#${colorscheme.colors.base00}"

  [colors.search.matches]
  background = "#${colorscheme.colors.base04}"
  foreground = "#${colorscheme.colors.base00}"

  [colors.selection]
  background = "#${colorscheme.colors.base06}"
  text = "#${colorscheme.colors.base00}"
''
