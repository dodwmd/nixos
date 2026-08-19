{
  lib,
  pkgs,
  ...
}: let
  # homelab.users.desktopUser always creates "dodwmd" (system/core/user-roles.nix)
  desktopUsername = "dodwmd";
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
      "x-scheme-handler/zoommtg" = "Zoom.desktop";
      "x-scheme-handler/zoomus" = "Zoom.desktop";
      "x-scheme-handler/tel" = "Zoom.desktop";
      "x-scheme-handler/callto" = "Zoom.desktop";
      "x-scheme-handler/zoomphonecall" = "Zoom.desktop";
      "x-scheme-handler/zoomphonesms" = "Zoom.desktop";
      "x-scheme-handler/zoomcontactcentercall" = "Zoom.desktop";
    }
    // image // video // audio // browserTypes;
in {
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    config = {
      common = {
        default = ["gnome" "gtk"];
        # Niri implements org.gnome.Mutter.ScreenCast D-Bus interface,
        # so the GNOME portal handles screen sharing (not wlr)
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
        "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
        # xdg-desktop-portal-gnome's OpenURI/"Open with" confirmation dialog
        # (backed by the AppChooser impl interface) crashes on markup
        # parsing when the target URI contains an unescaped "&" (e.g. Zoom's
        # zoommtg://...&errorno=0&... SSO handoff links), leaving the
        # request stuck with a garbled "no apps installed" dialog and the
        # app never launches. Use the gtk backend's plain (non-markup-crashy)
        # chooser dialog instead.
        "org.freedesktop.impl.portal.AppChooser" = ["gtk" "gnome"];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
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

  # xdg-desktop-portal resolves each candidate app's Exec binary with
  # access(X_OK) against its own $PATH before offering it in the OpenURI
  # "Open With" chooser. When this unit is D-Bus-activated it can end up
  # with systemd's bare compiled-in default $PATH (coreutils/findutils/
  # grep/sed/systemd only) instead of the real session PATH, so apps
  # installed only via the user profile (e.g. zoom-us's `zoom` binary in
  # /etc/profiles/per-user/<user>/bin) silently fail that check and never
  # appear as choices — the dialog looks empty/broken even though the app
  # is correctly registered as the default handler. Force the real PATH.
  systemd.user.services = let
    portalPath = lib.concatStringsSep ":" [
      "/run/wrappers/bin"
      "/etc/profiles/per-user/${desktopUsername}/bin"
      "/nix/var/nix/profiles/default/bin"
      "/run/current-system/sw/bin"
    ];
    withFixedPath = {
      environment.PATH = lib.mkForce portalPath;
    };
  in {
    xdg-desktop-portal = withFixedPath;
    xdg-desktop-portal-gtk = withFixedPath;
    xdg-desktop-portal-gnome = withFixedPath;
  };
}
