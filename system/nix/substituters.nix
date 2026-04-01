{
  nix.settings = {
    substituters = [
      # high priority since it's almost always used
      "https://cache.nixos.org?priority=10"

      "https://attic.xuyh0120.win/lantian"
      "https://fufexan.cachix.org"
      "https://linuxmobile.cachix.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "fufexan.cachix.org-1:LwCDjCJNJQf5XD2BV+yamQIMZfcKWR9ISIFy5curUsY="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "linuxmobile.cachix.org-1:2K7KEjzbd3U+qMQRte/DGqttosw8EGgGVvu8vKu8D6A="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
