{ lib, pkgs, ... }:

let
  extensions = with pkgs.gnomeExtensions; [
    blur-my-shell
    rounded-window-corners-reborn
  ];
in
{
  home.packages = with pkgs; [
    showtime
    # TODO: try new mission center when 1.0 is in nixpkgs
    # mission-center
    resources
    pinta
  ] ++ extensions;

  defaultApplications.imageViewer = "org.gnome.Loupe.desktop";
  defaultApplications.videoPlayer = "org.gnome.Showtime.desktop";

  gtk = {
    enable = true;

    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme=1
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme=1;
    };
  };

  dconf.settings = with lib.hm.gvariant;  {
    "org/gnome/desktop/background" = {
      picture-uri = "file://" + ./wallpaper.png;
      picture-uri-dark = "file://" + ./wallpaper.png;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "blue";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "com.mitchellh.ghostty.desktop"
        "discord.desktop"
        "spotify.desktop"
        "net.nokyan.Resources.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = map (e: e.extensionUuid) extensions;
      disabled-extensions = [];
    };

    "org/gnome/desktop/input-sources" = {
      sources = [
        (mkTuple [ "xkb" "us" ])
        (mkTuple [ "ibus" "mozc-jp" ])
        (mkTuple [ "xkb" "jp" ])
      ];
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      style-components = 2;
    };
  };
}
