{
  services.beszel.agent = {
    enable = true;
    environment = {
      KEY = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJongKPvEA333N3+vpQBYsFKGW7syD1IxsdswjiNlLdj beszel-hub";
      EXTRA_FILESYSTEMS = "/mnt";
      PACKAGE_UPDATES_INTERVAL = "0";
      SKIP_WIFI = "true";
    };
  };

  boot.kernel.sysctl."net.ipv4.ip_local_reserved_ports" = "45876";
}
