{ lib, pkgs, ... }:

let
  extensions = with pkgs.gnomeExtensions; [
    blur-my-shell
    rounded-window-corners-reborn
    clipboard-indicator
  ];
in
{
  home.packages = extensions;

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
      accent-color = "green";
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "zen-twilight.desktop"
        "org.gnome.Nautilus.desktop"
        "com.mitchellh.ghostty.desktop"
        "spotify.desktop"
        "discord.desktop"
        "io.missioncenter.MissionCenter.desktop"
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
  };
}
