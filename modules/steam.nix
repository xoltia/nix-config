{ pkgs, ... }:
{
  programs.steam.enable = true;
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
  programs.gamemode.enable = true;
  environment.systemPackages = [ pkgs.r2modman ];
}
