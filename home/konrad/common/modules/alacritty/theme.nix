{ colorscheme }:
''
  # Base16 ${colorscheme.slug} - alacritty color config
  colors:
    # Default colors
    primary:
      background: '#${colorscheme.colors.base00}'
      foreground: '#${colorscheme.colors.base05}'
      dim_foreground: '#${colorscheme.colors.base05}'
      bright_foreground: '#${colorscheme.colors.base05}'

    # Colors the cursor will use if `custom_cursor_colors` is true
    cursor:
      text: '#${colorscheme.colors.base00}'
      cursor: '#${colorscheme.colors.base06}'
    vi_mode_cursor:
      text: '#${colorscheme.colors.base00}'
      cursor: '#${colorscheme.colors.base07}'

    # Search colors
    search:
        matches:
            foreground: '#${colorscheme.colors.base00}'
            background: '#${colorscheme.colors.base04}'
        focused_match:
            foreground: '#${colorscheme.colors.base00}'
            background: '#${colorscheme.colors.base0B}'
        footer_bar:
            foreground: '#${colorscheme.colors.base00}'
            background: '#${colorscheme.colors.base04}'

    # Keyboard regex hints
    hints:
        start:
            foreground: '#${colorscheme.colors.base00}'
            background: '#${colorscheme.colors.base0A}'
        end:
            foreground: '#${colorscheme.colors.base00}'
            background: '#${colorscheme.colors.base04}'

    # Selection colors
    selection:
        text: '#${colorscheme.colors.base00}'
        background: '#${colorscheme.colors.base06}'

    # Normal colors
    normal:
      black:   '#${colorscheme.colors.base03}'
      red:     '#${colorscheme.colors.base08}'
      green:   '#${colorscheme.colors.base0B}'
      yellow:  '#${colorscheme.colors.base0A}'
      blue:    '#${colorscheme.colors.base0D}'
      magenta: '#${colorscheme.colors.base0F}'
      cyan:    '#${colorscheme.colors.base0C}'
      white:   '#${colorscheme.colors.base05}'

    # Bright colors
    bright:
      black:   '#${colorscheme.colors.base04}'
      red:     '#${colorscheme.colors.base08}'
      green:   '#${colorscheme.colors.base0B}'
      yellow:  '#${colorscheme.colors.base0A}'
      blue:    '#${colorscheme.colors.base0D}'
      magenta: '#${colorscheme.colors.base0F}'
      cyan:    '#${colorscheme.colors.base0C}'
      white:   '#${colorscheme.colors.base05}'

    # Dim colors
    dim:
      black:   '#${colorscheme.colors.base03}'
      red:     '#${colorscheme.colors.base08}'
      green:   '#${colorscheme.colors.base0B}'
      yellow:  '#${colorscheme.colors.base0A}'
      blue:    '#${colorscheme.colors.base0D}'
      magenta: '#${colorscheme.colors.base0F}'
      cyan:    '#${colorscheme.colors.base0C}'
      white:   '#${colorscheme.colors.base05}'

    indexed_colors:
        - { index: 16, color: "#${colorscheme.colors.base09}" }
        - { index: 17, color: "#${colorscheme.colors.base06}" }
''
