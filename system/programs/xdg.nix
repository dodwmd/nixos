{
  lib,
  pkgs,
  ...
}: let
  browser = ["brave-browser.desktop"];
  imageViewer = ["lightview.desktop"];
  videoPlayer = ["mpv.desktop"];
  audioPlayer = ["io.bassi.Amberol.desktop"];

  xdgAssociations = type: program: list:
    builtins.listToAttrs (map (e: {
        name = "${type}/${e}";
        value = builtins.head program;
      })
      list);

  image = xdgAssociations "image" imageViewer ["png" "jpg" "jpeg" "gif" "webp" "bmp" "tiff" "tif" "ico" "svg" "avif" "heic" "heif"];
  video = xdgAssociations "video" videoPlayer ["mp4" "avi" "mkv" "mov" "wmv" "flv" "webm" "m4v" "3gp" "ogv" "ts" "mts" "m2ts"];
  audio = xdgAssociations "audio" audioPlayer ["mp3" "flac" "wav" "aac" "ogg" "oga" "opus" "m4a" "wma" "ape" "alac" "aiff"];

  browserTypes =
    (xdgAssociations "application" browser ["json" "x-extension-htm" "x-extension-html" "x-extension-shtml" "x-extension-xht" "x-extension-xhtml"])
    // (xdgAssociations "x-scheme-handler" browser ["about" "ftp" "http" "https" "unknown"]);

  associations =
    {
      "application/pdf" = "org.gnome.Papers.desktop";
      "application/zip" = "org.gnome.FileRoller.desktop";
      "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
      "application/x-rar-compressed" = "org.gnome.FileRoller.desktop";
      "application/x-tar" = "org.gnome.FileRoller.desktop";
      "application/gzip" = "org.gnome.FileRoller.desktop";
      "text/html" = builtins.head browser;
      "text/plain" = "org.gnome.TextEditor.desktop";
      "text/markdown" = "org.gnome.TextEditor.desktop";
      "x-scheme-handler/chrome" = "brave-browser.desktop";
    }
    // image // video // audio // browserTypes;
in {
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    config = {
      common = {
        default = ["gnome" "gtk"];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-wlr  # Needed for niri/Wayland compositors
    ];
  };

  environment.etc."xdg/mimeapps.list".text = ''
    [Default Applications]
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") associations)}
    
    [Added Associations]
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") associations)}
  '';

  environment.sessionVariables = {
    NIX_XDG_DESKTOP_PORTAL_DIR = lib.mkForce null;
  };
}
