{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.twilight
    ./gnome.nix
    ./packages.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "luisl";
  home.homeDirectory = "/home/luisl";
  home.sessionVariables = {
    EDITOR = "hx";   
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
      BACKGROUND_JOBS="%(1j. %F{red}[%j]%f.)"
      PS1="%K{blue}%n@%m%k %B%F{cyan}%~%f$BACKGROUND_JOBS%b %F{250}%%%f "
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

  home.file.".config/ghostty/config".text = ''
    window-height = 30
    window-width = 120
    gtk-titlebar-hide-when-maximized = true
    window-padding-balance = true
    window-padding-color = extend
    theme = Adwaita Dark
  '';

  programs.home-manager.enable = true;

  # Probably don't change unless you're sure it won't break things.
  home.stateVersion = "25.05";
}
