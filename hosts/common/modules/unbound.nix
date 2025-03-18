{
  services.unbound = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      remote-control.control-enable = true;
      server = {
        # my main dns is blocky
        # unbound should only be used by blocky on the same machine
        interface = [ "127.0.0.1" ];
        port = 5335;
        access-control = [ "127.0.0.1/8 allow" ];

        hide-identity = true;
        hide-version = true;
        qname-minimisation = true;

        # will be defaults for unbound, but not yet
        private-address = [
          "192.168.0.0/16"
          "169.254.0.0/16"
          "172.16.0.0/12"
          "10.0.0.0/8"
          "fd00::/8"
          "fe80::/10"
        ];
      };
    };
  };
}
