{pkgs, ...}: {
  users.users.dodwmd = {
    isNormalUser = true;
    shell = pkgs.bash;
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
