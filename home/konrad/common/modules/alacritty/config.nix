{ fontFamily, fontSize }:
''
  live_config_reload: false

  window:
    dynamic_title: true
    padding:
      x: 6
      y: 6
    dynamic_padding: false
    option_as_alt: Both

  mouse:
    hide_when_typing: true

  scrolling:
    history: 5000

  cursor:
    style:
      shape: Block

  fontfamily: &fontfamily "${fontFamily}"
  font:
    size: ${toString fontSize}
    normal:
      family: *fontfamily
      style: Regular

    bold:
      family: *fontfamily
      style: Bold

    italic:
      family: *fontfamily
      style: Italic

    bold_italic:
      family: *fontfamily
      style: Bold Italic
''
