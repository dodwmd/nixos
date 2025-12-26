{
  lib,
  pkgs,
  ...
}: let
  qmlCandidates =
    [
      pkgs.quickshell
    ]
    ++ (with pkgs.kdePackages; [
      qtbase
      qtdeclarative
      qt6ct
      qtmultimedia
      qtwayland
      kirigami
    ]);

  requiredPackages = with pkgs; [
    accountsservice
    gsettings-desktop-schemas
    brightnessctl
    cava
    cliphist
    ddcutil
    elogind
    glib
    gpu-screen-recorder
    material-symbols
    matugen
    swww
    wl-clipboard
  ];

  allPackages = qmlCandidates ++ requiredPackages;

  quickshellWrapped = pkgs.symlinkJoin {
    name = "quickshell-wrapped";
    paths = allPackages;
    buildInputs = [pkgs.makeWrapper];

    postBuild = ''
      wrapProgram $out/bin/quickshell \
        --set QML2_IMPORT_PATH "${lib.makeSearchPath "lib/qt-6/qml" qmlCandidates}:${lib.makeSearchPath "lib/qt-5/qml" qmlCandidates}"
    '';
  };
in {
  users.users.linuxmobile.packages = [
    quickshellWrapped
  ];

  environment.sessionVariables.QML2_IMPORT_PATH =
    lib.makeSearchPath "lib/qt-6/qml" qmlCandidates
    + ":"
    + lib.makeSearchPath "lib/qt-5/qml" qmlCandidates;
}
