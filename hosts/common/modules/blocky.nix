{
  services.blocky = {
    enable = true;
    settings = {
      prometheus = {
        enable = false;
      };
      ports = {
        dns = 53;
        tls = 853;
        http = 4000;
      };
      upstreams = {
        groups = {
          default = [
            "1.1.1.1"
            "9.9.9.9"
            "8.8.8.8"
          ];
        };
      };
      blocking = {
        denylists = {
          ads = [
            "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "http://sysctl.org/cameleon/hosts"
            "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt"
          ];
          fakenews = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews/hosts"
          ];
        };
        clientGroupsBlock = {
          default = [
            "ads"
            "fakenews"
          ];
        };
      };
    };
  };
}
