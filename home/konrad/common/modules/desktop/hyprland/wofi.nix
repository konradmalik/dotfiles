{
  config,
  ...
}:
let
  fontSize = config.fontProfiles.monospace.size;
  fontFamily = config.fontProfiles.monospace.family;
in
{
  xdg.configFile."wofi/style.css".text = ''
    * {
      font-family: '${fontFamily}', monospace;
      font-size: ${toString fontSize}px;
    }

    window {
      margin: 0px;
      padding: 20px;
      background-color: #${config.colorscheme.palette.base00};
      opacity: 0.95;
    }

    #inner-box {
      margin: 0;
      padding: 0;
      border: none;
      background-color: #${config.colorscheme.palette.base00};
    }

    #outer-box {
      margin: 0;
      padding: 20px;
      border: none;
      background-color: #${config.colorscheme.palette.base00};
    }

    #scroll {
      margin: 0;
      padding: 0;
      border: none;
      background-color: #${config.colorscheme.palette.base00};
    }

    #input {
      margin: 0;
      padding: 10px;
      border: none;
      background-color: #${config.colorscheme.palette.base00};
      color: @text;
    }

    #input:focus {
      outline: none;
      box-shadow: none;
      border: none;
    }

    #text {
      margin: 5px;
      border: none;
      color: #${config.colorscheme.palette.base06};
    }

    #entry {
      background-color: #${config.colorscheme.palette.base00};
    }

    #entry:selected {
      outline: none;
      border: none;
    }

    #entry:selected #text {
      color: #${config.colorscheme.palette.base02};
    }

    #entry image {
      -gtk-icon-transform: scale(0.7);
    }
  '';

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 350;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = config.colorscheme.variant == "dark";
    };
  };
}
