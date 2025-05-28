{ pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    jq
    zip
    unzip
    ffmpeg
    imagemagick
    fastfetch
    mission-center
    spotify
    discord
    lazygit
    qemu_full
    quickemu
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    (import ../pkgs/jido.nix { inherit pkgs; })
  ];
}
