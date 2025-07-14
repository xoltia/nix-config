{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ../../hm-modules/base-packages.nix
    ../../hm-modules/git.nix
    ../../hm-modules/helix.nix
    ../../hm-modules/direnv.nix
    ../../hm-modules/zsh.nix
  ];
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
  basePackages.enableQemu = false;
  basePackages.enableGuiApps = false;
  basePackages.enableFonts = false;
}
