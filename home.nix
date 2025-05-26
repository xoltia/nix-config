{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.twilight
  ];

  home.username = "luisl";
  home.homeDirectory = "/home/luisl";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    gnomeExtensions.blur-my-shell
    ghostty
    mission-center
    spotify
    discord
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  home.sessionVariables = {
    EDITOR = "hx";   
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  dconf.settings = with lib.hm.gvariant;  {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "zen-twilight.desktop"
        "org.gnome.Nautilus.desktop"
        "com.mitchellh.ghostty.desktop"
        "spotify.desktop"
        "discord.desktop"
        "io.missioncenter.MissionCenter.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "blur-my-shell@aunetx"
      ];
      disabled-extensions = [];
    };
    "org/gnome/desktop/input-sources" = {
      sources = [
        (mkTuple [ "xkb" "us" ])
        (mkTuple [ "ibus" "mozc-jp" ])
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };
  };

  programs.git = {
    enable = true;
    userName  = "Juan Llamas";
    userEmail = "38849891+xoltia@users.noreply.github.com";
    extraConfig.init.defaultBranch = "main";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable= true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
    };
    history.size = 10000;
    initContent  = ''
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      prompt adam1
    '';
  };

  programs.helix = {
    enable = true;
    settings = {
      editor = {
        line-number = "relative";
        bufferline = "multiple";
        color-modes = true;
      };
    };
  };

  programs.zen-browser = {
    enable = true;
    policies.DisableTelemetry = true;
    policies.DisableAppUpdate = true;
  };

  programs.home-manager.enable = true;

  home.file.".config/ghostty/config".text = ''
    window-height = 30
    window-width = 120
    gtk-titlebar-hide-when-maximized = true
    window-padding-balance = true
    window-padding-color = extend
    theme = Adwaita Dark
  '';
}
