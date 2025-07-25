{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ../../hm-modules/base-packages.nix
    ../../hm-modules/default-applications.nix
    ../../hm-modules/gnome.nix
    ../../hm-modules/git.nix
    ../../hm-modules/firefox.nix
    ../../hm-modules/helix.nix
    ../../hm-modules/direnv.nix
    ../../hm-modules/zsh.nix
    ../../hm-modules/ghostty.nix
    ../../hm-modules/stash.nix
  ];
  home.username = "luisl";
  home.homeDirectory = "/home/luisl";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
