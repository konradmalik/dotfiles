{
  fontFamily,
  fontSize,
  theme,
}:
# it's not toml, but close enough for highlights
# toml
''
  auto-update = off
  gtk-single-instance = true
  gtk-titlebar = false
  font-family = ${fontFamily}
  font-size = ${toString fontSize}
  mouse-hide-while-typing = true
  theme = ${theme}
''
