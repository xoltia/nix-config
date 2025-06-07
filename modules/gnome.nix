{ lib, pkgs, ... }:

{ 
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  networking.networkmanager.settings.connectivity.uri = "http://nmcheck.gnome.org/check_network_status.txt";

  environment.variables = {
    MUTTER_DEBUG_FORCE_KMS_MODE = "simple";
  };

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
}
