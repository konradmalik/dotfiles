{
  disko.devices.disk = {
    sdb = {
      device = "/dev/sdb";
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
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
            start = "500MiB";
            end = "100%";
            part-type = "primary";
            bootable = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          }
        ];
      };
    };
    sda = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "home";
            type = "partition";
            start = "1MiB";
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
}