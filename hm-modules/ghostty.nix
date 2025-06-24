{ pkgs, ... }:

{
  programs.ghostty.enable = true;
  programs.ghostty.settings = {
    window-height = 35;
    window-width = 120;
    gtk-titlebar-hide-when-maximized = true;
    window-padding-balance = true;
    window-padding-color = "extend";
    theme = "Adwaita Dark";
    mouse-hide-while-typing = true;
  };
}

