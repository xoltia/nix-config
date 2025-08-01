{ pkgs, lib, config, ... }:

{
  options.basePackages = with lib; {
    enableGuiApps = mkOption {
      type = types.bool;
      default = true;
      description = "Enable inclusion of GUI applications.";
    };
    enableQemu = mkOption {
      type = types.bool;
      default = true;
      description = "Enable QEMU packages.";
    };
    enableFonts = mkOption {
      type = types.bool;
      default = true;
      description = "Enable font packages.";
    };
  };

  config = {
    home.packages = with pkgs;
      [
        file
        jq
        zip
        unzip
        ripgrep
        fd
        ffmpeg
        imagemagick
        fastfetch
      ]
      ++ lib.optionals config.basePackages.enableFonts [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
      ]
      ++ lib.optionals config.basePackages.enableQemu [
        qemu_full
        quickemu
      ]
      ++ lib.optionals config.basePackages.enableGuiApps [
        spotify
        discord
        amberol
        gimp3
        (bottles.override { removeWarningPopup = true; })
      ];
  };
}
