_: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-38.7.1"
        "electron-39.8.10"
      ];
    };
  };
}
