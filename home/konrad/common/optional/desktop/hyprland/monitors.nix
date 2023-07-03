# Convert config.monitors into hyprland's format
{ lib, monitors }:
with lib;
concatStringsSep "\n" (map
  (m:
  if m.enabled then
    ''
      monitor=${m.name},${toString m.width}x${toString m.height}@${toString m.refreshRate},${toString m.x}x${toString m.y},${toString m.scale}
      ${lib.optionalString (m.workspace != null)"workspace=${m.name},${m.workspace}"}
    ''
  else
    ''
      monitor=${m.name},disable
    ''
  )
  monitors
)
