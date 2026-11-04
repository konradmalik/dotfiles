{ config, lib, ... }:
let
  aerospace = lib.getExe' config.services.aerospace.package "aerospace";

  screenshot =
    flags:
    "exec-and-forget mkdir -p /tmp/screenshots && screencapture -i ${flags} /tmp/screenshots/$(date +%Y-%m-%d-%H%M%S).png";

  directions = {
    left = "h";
    down = "j";
    up = "k";
    right = "l";
  };

  directionBindings = lib.concatMapAttrs (
    dir: vimKey:
    lib.mergeAttrsList (
      map
        (key: {
          "alt-${key}" = "focus ${dir}";
          "alt-shift-${key}" = "move ${dir}";
          "alt-ctrl-${key}" = "focus-monitor ${dir}";
          "alt-ctrl-shift-${key}" = "move-node-to-monitor --focus-follows-window ${dir}";
          "alt-cmd-${key}" = "move-workspace-to-monitor ${dir}";
        })
        [
          dir
          vimKey
        ]
    )
  ) directions;

  workspaceBindings = lib.mergeAttrsList (
    lib.genList (
      i:
      let
        key = toString (lib.mod (i + 1) 10);
        # padded so they sort
        name = lib.fixedWidthNumber 2 (i + 1);
      in
      {
        "alt-${key}" = "workspace ${name}";
        "alt-shift-${key}" = "move-node-to-workspace ${name}";
      }
    ) 10
  );

  scratchpad = "S";
in
{
  services.aerospace = {
    enable = true;
    settings = {
      gaps = {
        inner = {
          horizontal = 5;
          vertical = 5;
        };
        outer = {
          left = 10;
          bottom = 10;
          top = 10;
          right = 10;
        };
      };

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      mode.main.binding = {
        # Program bindings
        alt-enter = "exec-and-forget open -na Ghostty";
        alt-b = "exec-and-forget open -a '${config.users.users.konrad.home}/Applications/Home Manager Apps/Zen Browser (Beta).app'";

        # Screenshots
        alt-p = screenshot "";
        # annotate in preview
        alt-shift-p = screenshot "-P";

        # Window manager controls
        alt-shift-q = "close";
        alt-f = "fullscreen";
        alt-shift-f = "macos-native-fullscreen";
        alt-shift-space = "layout floating tiling";
        alt-minus = "resize smart -50";
        alt-shift-minus = "resize smart -70";
        alt-equal = "resize smart +50";
        alt-shift-equal = "resize smart +70";

        alt-g = "layout accordion tiles";

        # Cycle / swap windows
        alt-tab = "focus --boundaries-action wrap-around-the-workspace dfs-next";
        alt-shift-tab = "focus --boundaries-action wrap-around-the-workspace dfs-prev";
        alt-ctrl-tab = "swap --wrap-around dfs-next";
        alt-ctrl-shift-tab = "swap --wrap-around dfs-prev";

        # Scratchpad
        alt-u = "exec-and-forget [ \"$(${aerospace} list-workspaces --focused)\" = ${scratchpad} ] && ${aerospace} workspace-back-and-forth || ${aerospace} workspace ${scratchpad}";
        alt-shift-u = "move-node-to-workspace ${scratchpad}";
      }
      // directionBindings
      // workspaceBindings;
    };
  };

  # recommended by aerospace, turns off "displays have separate spaces" (needs a logout)
  system.defaults.spaces.spans-displays = true;

  # colors come from stylix
  services.jankyborders = {
    enable = true;
    width = 2.0;
    style = "round";
  };
}
