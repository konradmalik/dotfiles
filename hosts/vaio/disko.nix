{
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "boot";
              start = "1MiB";
              end = "500MiB";
              part-type = "primary";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "root";
              start = "500MiB";
              end = "100%";
              part-type = "primary";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
          ];
        };
      };
      sdb = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "home";
              start = "1M";
              end = "100%";
              part-type = "primary";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            }
          ];
        };
      };
    };
  };
}
