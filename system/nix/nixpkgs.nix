_: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-38.7.1"
      ];
    };
  };
}
