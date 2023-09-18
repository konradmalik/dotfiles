{
  disko.devices.disk = {
    sdb = {
      device = "/dev/sdb";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            start = "1MiB";
            end = "500MiB";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            start = "500MiB";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
    sda = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          home = {
            start = "1MiB";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
        };
      };
    };
  };
}
