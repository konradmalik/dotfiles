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
              type = "partition";
              start = "1MiB";
              end = "500MiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "root";
              type = "partition";
              part-type = "primary";
              start = "500MiB";
              end = "100%";
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
              type = "partition";
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
