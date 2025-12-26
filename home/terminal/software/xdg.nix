{
  config,
  pkgs,
  lib,
  ...
}: let
  browser = ["helium.desktop"];
  imageViewer = ["lightview.desktop"];
  videoPlayer = ["mpv.desktop"];
  audioPlayer = ["io.bassi.Amberol.desktop"];

  xdgAssociations = type: program: list:
    builtins.listToAttrs (map (e: {
        name = "${type}/${e}";
        value = program;
      })
      list);

  image = xdgAssociations "image" imageViewer [
    "png"
    "jpg"
    "jpeg"
    "gif"
    "webp"
    "bmp"
    "tiff"
    "tif"
    "ico"
    "svg"
    "avif"
    "heic"
    "heif"
  ];

  video = xdgAssociations "video" videoPlayer [
    "mp4"
    "avi"
    "mkv"
    "mov"
    "wmv"
    "flv"
    "webm"
    "m4v"
    "3gp"
    "ogv"
    "ts"
    "mts"
    "m2ts"
  ];

  audio = xdgAssociations "audio" audioPlayer [
    "mp3"
    "flac"
    "wav"
    "aac"
    "ogg"
    "oga"
    "opus"
    "m4a"
    "wma"
    "ape"
    "alac"
    "aiff"
  ];

  browserTypes =
    (xdgAssociations "application" browser [
      "json"
      "x-extension-htm"
      "x-extension-html"
      "x-extension-shtml"
      "x-extension-xht"
      "x-extension-xhtml"
    ])
    // (xdgAssociations "x-scheme-handler" browser [
      "about"
      "ftp"
      "http"
      "https"
      "unknown"
    ]);

  associations =
    {
      "application/pdf" = ["org.gnome.Papers.desktop"];
      "application/zip" = ["org.gnome.FileRoller.desktop"];
      "application/x-7z-compressed" = ["org.gnome.FileRoller.desktop"];
      "application/x-rar-compressed" = ["org.gnome.FileRoller.desktop"];
      "application/x-tar" = ["org.gnome.FileRoller.desktop"];
      "application/gzip" = ["org.gnome.FileRoller.desktop"];
      "text/html" = browser;
      "text/plain" = ["org.gnome.TextEditor.desktop"];
      "text/markdown" = ["org.gnome.TextEditor.desktop"];
      "text/x-python" = ["org.gnome.TextEditor.desktop"];
      "text/x-shellscript" = ["org.gnome.TextEditor.desktop"];
      "application/json" = ["org.gnome.TextEditor.desktop"];
      "application/xml" = ["org.gnome.TextEditor.desktop"];
      "application/javascript" = ["org.gnome.TextEditor.desktop"];
      "text/css" = ["org.gnome.TextEditor.desktop"];
      "text/x-c" = ["org.gnome.TextEditor.desktop"];
      "text/x-c++" = ["org.gnome.TextEditor.desktop"];
      "text/x-rust" = ["org.gnome.TextEditor.desktop"];
      "text/x-nix" = ["org.gnome.TextEditor.desktop"];
      "x-scheme-handler/chrome" = ["helium.desktop"];
    }
    // image // video // audio // browserTypes;

  userDirsConfig = pkgs.writeText "user-dirs.dirs" ''
    XDG_DESKTOP_DIR="$HOME/Desktop"
    XDG_DOWNLOAD_DIR="$HOME/Downloads"
    XDG_TEMPLATES_DIR="$HOME/Templates"
    XDG_PUBLICSHARE_DIR="$HOME/Public"
    XDG_DOCUMENTS_DIR="$HOME/Documents"
    XDG_MUSIC_DIR="$HOME/Music"
    XDG_PICTURES_DIR="$HOME/Pictures"
    XDG_VIDEOS_DIR="$HOME/Videos"
    XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
  '';
in {
  users.users.linuxmobile.packages = with pkgs; [
    xdg-utils
    (writeShellScriptBin "xdg-terminal-exec" ''
      foot start "$@"
    '')
  ];

  xdg = {
    mime = {
      enable = true;
      defaultApplications = associations;
    };
    configFile."user-dirs.dirs".source = userDirsConfig;
    configFile."mimeapps.list".text = let
      mkSection = name: apps:
        "[${name}]\n"
        + (lib.concatStringsSep "\n"
          (lib.mapAttrsToList (k: v: "${k}=${lib.concatStringsSep ";" v}") apps));
    in ''
      ${mkSection "Default Applications" associations}
      ${mkSection "Added Associations" associations}
    '';
  };

  environment.sessionVariables = {
    XDG_CONFIG_HOME = config.xdg.configHome;
    XDG_CACHE_HOME = config.xdg.cacheHome;
    XDG_DATA_HOME = config.xdg.dataHome;
    XDG_STATE_HOME = config.xdg.stateHome;
    XDG_RUNTIME_DIR = config.xdg.runtimeDir;
  };
}
