{ colorscheme }:
let
  c = colorscheme.palette;
in
''
  # Base16 ${colorscheme.slug} - alacritty color config

  [[colors.indexed_colors]]
  color = "#${c.base09}"
  index = 16

  [[colors.indexed_colors]]
  color = "#${c.base06}"
  index = 17

  [colors.bright]
  black = "#${c.base04}"
  blue = "#${c.base0D}"
  cyan = "#${c.base0C}"
  green = "#${c.base0B}"
  magenta = "#${c.base0F}"
  red = "#${c.base08}"
  white = "#${c.base05}"
  yellow = "#${c.base0A}"

  [colors.cursor]
  cursor = "#${c.base06}"
  text = "#${c.base00}"

  [colors.vi_mode_cursor]
  cursor = "#${c.base07}"
  text = "#${c.base00}"

  [colors.dim]
  black = "#${c.base03}"
  blue = "#${c.base0D}"
  cyan = "#${c.base0C}"
  green = "#${c.base0B}"
  magenta = "#${c.base0F}"
  red = "#${c.base08}"
  white = "#${c.base05}"
  yellow = "#${c.base0A}"

  [colors.hints.end]
  background = "#${c.base04}"
  foreground = "#${c.base00}"

  [colors.hints.start]
  background = "#${c.base0A}"
  foreground = "#${c.base00}"

  [colors.normal]
  black = "#${c.base03}"
  blue = "#${c.base0D}"
  cyan = "#${c.base0C}"
  green = "#${c.base0B}"
  magenta = "#${c.base0F}"
  red = "#${c.base08}"
  white = "#${c.base05}"
  yellow = "#${c.base0A}"

  [colors.primary]
  background = "#${c.base00}"
  bright_foreground = "#${c.base05}"
  dim_foreground = "#${c.base05}"
  foreground = "#${c.base05}"

  [colors.search.focused_match]
  background = "#${c.base0B}"
  foreground = "#${c.base00}"

  [colors.footer_bar]
  background = "#${c.base04}"
  foreground = "#${c.base00}"

  [colors.search.matches]
  background = "#${c.base04}"
  foreground = "#${c.base00}"

  [colors.selection]
  background = "#${c.base06}"
  text = "#${c.base00}"
''
