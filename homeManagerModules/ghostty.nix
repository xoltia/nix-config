{ pkgs, ... }:

{
  home.packages = with pkgs; [ ghostty ];

  home.file.".config/ghostty/config".text = ''
    window-height = 30
    window-width = 120
    gtk-titlebar-hide-when-maximized = true
    window-padding-balance = true
    window-padding-color = extend
    theme = Adwaita Dark
    mouse-hide-while-typing = true
  '';
}

