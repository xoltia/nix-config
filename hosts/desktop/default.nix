{ config, pkgs, ... }:

{
  imports = [ ../modules/nvidia.nix ];

  hardware.pulseaudio.configFile = pkgs.runCommand "default.pa" {} ''
    sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
      ${pkgs.pulseaudio}/etc/pulse/default.pa > $out
  '';

  programs.steam.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = (with pkgs; [
    bottles
    cartridges
    osu-lazer-bin
    prismlauncher
  ]);

  system.stateVersion = "23.11";
}
