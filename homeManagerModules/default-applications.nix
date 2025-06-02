{ config, lib, pkgs, ... }:

let
  inherit (lib) mkOption types mkMerge;

  mimeMap = mimeTypes: desktopFile: builtins.listToAttrs
    (map (m: { name = m; value = desktopFile; }) mimeTypes);

  applyMimeType = mimeTypes: desktopFile:
    if desktopFile == "" then []
    else mimeMap mimeTypes desktopFile;
in
{
  options.defaultApplications = {
    imageViewer = mkOption {
      type = types.str;
      default = "";
    };
    videoPlayer = mkOption {
      type = types.str;
      default = "";
    };
    browser = mkOption {
      type = types.str;
      default = "firefox.dektop";
    };
  };

  config.xdg.mimeApps = {
    enable = true;
    defaultApplications = with config.defaultApplications;
      mkMerge [ 
        (applyMimeType [
          "image/jpeg"
          "image/png"
          "image/gif"
          "image/webp"
          "image/tiff"
          "image/x-tga"
          "image/vnd-ms.dds"
          "image/x-dds"
          "image/bmp"
          "image/vnd.microsoft.icon"
          "image/vnd.radiance"
          "image/x-exr"
          "image/x-portable-bitmap"
          "image/x-portable-graymap"
          "image/x-portable-pixmap"
          "image/x-portable-anymap"
          "image/x-qoi"
          "image/qoi"
          "image/svg+xml"
          "image/svg+xml-compressed"
          "image/avif"
          "image/heic"
          "image/jxl"
        ] imageViewer)
        (applyMimeType [
          "video/3gpp"
          "video/3gpp2"
          "video/h261"
          "video/h263"
          "video/h264"
          "video/jpeg"
          "video/jpm"
          "video/mj2"
          "video/mp2t"
          "video/mp4"
          "video/mpeg"
          "video/ogg"
          "video/quicktime"
          "video/vnd.fvt"
          "video/vnd.mpegurl"
          "video/vnd.ms-playready.media.pyv"
          "video/vnd.vivo"
          "video/webm"
          "video/x-f4v"
          "video/x-fli"
          "video/x-flv"
          "video/x-m4v"
          "video/x-matroska"
          "video/x-ms-asf"
          "video/x-ms-wm"
          "video/x-ms-wmv"
          "video/x-ms-wmx"
          "video/x-ms-wvx"
          "video/x-msvideo"
          "video/x-sgi-movie"
        ] videoPlayer)
        (applyMimeType [
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/chrome"
          "text/html"
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/xhtml+xml"
          "application/x-extension-xhtml"
          "application/x-extension-xht"
        ] browser)
      ];
  };
}

