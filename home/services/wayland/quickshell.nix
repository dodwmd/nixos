{
  pkgs,
  inputs,
  lib,
  ...
}: let
  quickshell = inputs.quickshell.packages.${pkgs.system}.default;
in {
  home.packages = with pkgs;
    [
      quickshell
    ]
    ++ [
      accountsservice
      adw-gtk3
      brightnessctl
      cava
      cliphist
      ddcutil
      elogind
      glib
      inputs.dms-cli.packages.${pkgs.system}.default
      inputs.mynixpkgs.packages.${pkgs.system}.dgop
      kdePackages.qt6ct
      kdePackages.qtmultimedia
      khal
      libsForQt5.qt5ct
      material-symbols
      matugen
      swww
      wl-clipboard
    ];

  home.sessionVariables.QML2_IMPORT_PATH = lib.concatStringsSep ":" [
    "${quickshell}/lib/qt-6/qml"
    "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml"
    "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    "${pkgs.kdePackages.qtmultimedia}/lib/qt-6/qml"
  ];
}
