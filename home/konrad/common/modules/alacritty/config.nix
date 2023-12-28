{ fontFamily, fontSize }:
''
  live_config_reload = false

  [cursor.style]
  shape = "Block"

  [font]
  size = ${toString fontSize}

  [font.bold]
  family = "${fontFamily}"
  style = "Bold"

  [font.bold_italic]
  family = "${fontFamily}"
  style = "Bold Italic"

  [font.italic]
  family = "${fontFamily}"
  style = "Italic"

  [font.normal]
  family = "${fontFamily}"
  style = "Regular"

  [mouse]
  hide_when_typing = true

  [scrolling]
  history = 5000

  [window]
  dynamic_padding = false
  dynamic_title = true
  option_as_alt = "Both"

  [window.padding]
  x = 6
  y = 6
''
