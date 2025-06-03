{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ../../homeManagerModules/base-packages.nix
    ../../homeManagerModules/default-applications.nix
    ../../homeManagerModules/gnome.nix
    ../../homeManagerModules/git.nix
    ../../homeManagerModules/zen.nix
    ../../homeManagerModules/helix.nix
    ../../homeManagerModules/direnv.nix
    ../../homeManagerModules/zsh.nix
    ../../homeManagerModules/ghostty.nix
    ../../homeManagerModules/stash.nix
  ];
  nixpkgs.config.allowUnfree = true;
  home.username = "luisl";
  home.homeDirectory = "/home/luisl";
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}
