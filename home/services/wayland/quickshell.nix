{
  pkgs,
  lib,
  ...
}: {
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
      gpu-screen-recorder
      kdePackages.qt6ct
      kdePackages.qtmultimedia
      libsForQt5.qt5ct
      material-symbols
      matugen
      swww
      wl-clipboard
    ];

  systemd.user.sessionVariables.QML2_IMPORT_PATH = lib.concatStringsSep ":" [
    "${pkgs.quickshell}/lib/qt-6/qml"
    "${pkgs.kdePackages.qtbase}/lib/qt-6/qml"
    "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml"
    "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
    "${pkgs.kdePackages.qtmultimedia}/lib/qt-6/qml"
  ];
}
