{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnomeExtensions.blur-my-shell
    ghostty
    mission-center
    spotify
    discord
    lazygit
    qemu_full
    quickemu
    jq
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];
}
