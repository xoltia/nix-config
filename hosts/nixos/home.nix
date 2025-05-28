{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ../../homeManagerModules/gnome.nix
    ../../homeManagerModules/packages.nix
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/zen.nix
    ../../homeManagerModules/helix.nix
    ../../homeManagerModules/direnv.nix
    ../../homeManagerModules/zsh.nix
    ../../homeManagerModules/ghostty.nix
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = "luisl";
  home.homeDirectory = "/home/luisl";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
