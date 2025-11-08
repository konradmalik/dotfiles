{
  fontSize,
  fontFamily,
  writeTextDir,
}:
writeTextDir "fonts.lua"
  # lua
  ''
    local wezterm = require('wezterm')

    return {
      setup = function(config)
        config.font_size = ${toString fontSize}
        config.font = wezterm.font('${fontFamily}')
      end
    }
  ''
