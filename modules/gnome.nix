{ lib, pkgs, ... }:

{ 
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  networking.networkmanager.settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";
  
  environment.systemPackages = with pkgs; [
    ffmpegthumbnailer
  ];

  environment.gnome.excludePackages = (with pkgs; [
    totem
    epiphany
    geary
    cheese
    gnome-maps
    gnome-music
    gnome-tour
    gnome-contacts
  ]);

  environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
    lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);


  xdg.terminal-exec.enable = true;
  xdg.terminal-exec.settings = {
    GNOME = [
      "com.mitchellh.ghostty.desktop"
      "org.gnome.Console.desktop"
    ];
  };
}
