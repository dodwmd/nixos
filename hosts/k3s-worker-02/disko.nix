{
  disko.devices.disk.main = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          priority = 1;
          label = "boot";
          size = "487M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["fmask=0022" "dmask=0022"];
          };
        };
        swap = {
          priority = 2;
          label = "swap";
          size = "8G";
          content = {
            type = "swap";
          };
        };
        root = {
          priority = 3;
          label = "nixos";
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
