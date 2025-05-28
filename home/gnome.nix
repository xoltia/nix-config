{ lib, ... }:

{
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
      enabled-extensions = [
        "blur-my-shell@aunetx"
      ];
      disabled-extensions = [];
    };

    "org/gnome/desktop/input-sources" = {
      sources = [
        (mkTuple [ "xkb" "us" ])
        (mkTuple [ "ibus" "mozc-jp" ])
      ];
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };
  };
}
