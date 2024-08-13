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
        -- this disables ligatures
        config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
        config.font_size = ${toString fontSize}
        config.font = wezterm.font('${fontFamily}')
      end
    }

  ''
