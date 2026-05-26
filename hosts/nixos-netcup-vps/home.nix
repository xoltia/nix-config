{ ... }:
{
  imports = [
    ../../hm-modules/git.nix
    ../../hm-modules/helix.nix
    ../../hm-modules/zsh.nix
  ];
  home.username = "luisl";
  home.homeDirectory = "/home/luisl";
  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
