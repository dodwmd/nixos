{pkgs, ...}: {
  users.users.linuxmobile = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "adbusers"
      "input"
      "networkmanager"
      "plugdev"
      "video"
      "wheel"
      "kvm"
    ];
  };
}
