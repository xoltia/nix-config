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
    ffmpeg
    imagemagick
    fastfetch
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (import ../pkgs/jido.nix { inherit pkgs; })
  ];
}
