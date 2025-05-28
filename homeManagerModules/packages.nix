{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ghostty
    mission-center
    spotify
    discord
    lazygit
    qemu_full
    quickemu
    ffmpeg
    file
    jq
    zip
    unzip
    imagemagick
    fastfetch
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (import ../pkgs/jido.nix { inherit pkgs; })
  ];
}
