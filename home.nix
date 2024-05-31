{ config, pkgs, pkgs-unstable, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "luisl";
  home.homeDirectory = "/home/luisl";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.psmisc
    pkgs.xbindkeys
    pkgs.xautomation
    pkgs.gnomeExtensions.blur-my-shell
    pkgs.gnomeExtensions.rounded-window-corners
    pkgs-unstable.fastfetch
    pkgs.adw-gtk3
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    "firefox-gnome-theme" = {
      target = ".mozilla/firefox/default/chrome/firefox-gnome-theme";
      source = (fetchTarball {
          url = "https://codeload.github.com/rafaelmardojai/firefox-gnome-theme/tar.gz/refs/tags/v126";
          sha256 = "1r6vvhzk8gwhs78k54ppsxzfkw7lbldjivydy87ij6grj3cf6mld";
        });
    };

    ".xbindkeysrc" = {
      text = ''
        "xte 'keydown Control_L' 'keydown Alt_L' 'key Left' 'keyup Control_L' 'keyup Alt_L'"
          b:9
        "xte 'keydown Control_L' 'keydown Alt_L' 'key Right' 'keyup Control_L' 'keyup Alt_L'"
          b:8
      '';
    };

    "settings.json" = {
      target = ".config/Code/User/settings.json";
      text = ''
      {
        "workbench.iconTheme": "material-icon-theme",
        "window.titleBarStyle": "native",
        "[go]": {
            "editor.semanticHighlighting.enabled": true,
            "editor.insertSpaces": false,
            "editor.formatOnSave": true,
            "editor.codeActionsOnSave": {
                "source.organizeImports": "explicit"
            }
        },
        "workbench.colorTheme": "Adwaita Dark",
        "editor.fontFamily": "'MesloLGMDZ Nerd Font Mono'",
        "zig.path": "zig",
        "zig.zls.path": "zls",
        "zig.initialSetupDone": true,
        "glassit.alpha": 240,
        "update.mode": "manual"
      }
      '';
    };

    "hx-config" = {
      target = ".config/helix/config.toml";
      text = ''
        theme = "adwaita-dark"
      '';
    };
  };

  systemd.user.services = {
    xbindkeys = {
      Unit = {
        Description = "XBindKeys";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.xbindkeys}/bin/xbindkeys -n";
        Restart = "always";
      };
    };
  };

  home.activation = {
    reloadXBindKeys = lib.hm.dag.entryAfter [ "installPackages" ] ''
      $DRY_RUN_CMD ${pkgs.systemd}/bin/systemctl --user reload-or-restart xbindkeys
    '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/luisl/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Configure zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza --icons";
      ll = "eza --icons --git --long";
      c = "code . & disown; exit";
      update = "sudo nixos-rebuild switch --show-trace --flake /etc/nixos#default";
    };
    history.size = 10000;
    initExtra = ''
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      prompt adam1
      fastfetch -c paleofetch.jsonc
    '';
  };

  # Configure git user
  programs.git = {
    enable = true;
    userName  = "Juan Llamas";
    userEmail = "38849891+xoltia@users.noreply.github.com";
    extraConfig.init.defaultBranch = "main";
  };

  # Configure firefox porfile
  programs.firefox = {
    enable = true;
    profiles.default = {
      name = "Default";
      settings = {
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.drawInTitlebar" = true;
        "svg.context-properties.content.enabled" = true;
      };
      userChrome = ''
        @import "firefox-gnome-theme/userChrome.css";
        @import "firefox-gnome-theme/theme/colors/dark.css"; 
      '';
    };
  };

  gtk = {
    enable = true;
    theme = {
      # name = "Adwaita-dark";
      name = "adw-gtk3-dark";
    };
  };

  dconf = with lib.hm.gvariant; {
    enable = true;
    settings = {
      "org/gnome/mutter" = {
        center-new-windows = true;
        dynamic-workspaces = true;
        edge-tiling = true;
      };
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/shell".enabled-extensions = [
        "blur-my-shell@aunetx"
        "rounded-window-corners@yilozt"
      ];
      "org/gnome/shell/extensions/blur-my-shell/overview".style-components = 2;
      "org/gnome/shell/extensions/blur-my-shell".color-and-noise = false;
      "org/gnome/shell/extensions/blur-my-shell/applications".blur = false;
      "org/gnome/shell/extensions/blur-my-shell/panel".blur = false;
      "org/gnome/settings-daemon/plugins/media-keys" = {
        play = [ "<Ctrl><Alt>slash" ];
        next = [ "<Ctrl><Alt>period" ];
        previous = [ "<Ctrl><Alt>comma" ];
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "open kgx";
        command = "kgx";
        binding = "<Ctrl><Alt>t";
      };
      "org/gnome/desktop/input-sources" = {
        sources = [
          (mkTuple [ "xkb" "us" ])
          (mkTuple [ "ibus" "mozc-jp" ])
        ];
      };
      "org/gnome/shell".favorite-apps = [
        "firefox.desktop"
        "org.gnome.Console.desktop"
        "org.gnome.Nautilus.desktop"
        "code.desktop"
        "spotify.desktop"
        "discord.desktop"
      ];
    };
  };
}
