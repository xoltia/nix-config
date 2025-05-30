{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/helix.nix
  ];
  home.username = "luisl";
  home.homeDirectory = "/home/luisl";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
