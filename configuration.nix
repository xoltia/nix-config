# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;

  users.users.luisl = {
    isNormalUser = true;
    description = "Juan Llamas";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = [
      # pkgs.xbindkeys
      # pkgs.xautomation
      # pkgs.gnomeExtensions.blur-my-shell
      # pkgs.gnomeExtensions.rounded-window-corners
      # pkgs-unstable.fastfetch
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit pkgs-unstable;
      stateVersion = config.system.stateVersion;
    };
    users = {
      "luisl" = import ./home.nix;
    };
  };

  # Add local bin to PATH
  environment.localBinInPath = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = (with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        golang.go
        pkief.material-icon-theme
        github.copilot
        ms-vscode.cpptools
        ms-python.python
        piousdeer.adwaita-theme
      ] ++ vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vscord";
          publisher = "leonardssh";
          version = "5.2.9";
          sha256 = "1c9bd5a57d9c6ad8af772c6c9d58c9051bc84f09a4ca859e85a7d62fde52d81d";
        }
        {
          name = "vscode-zig";
          publisher = "ziglang";
          version = "0.5.8";
          sha256 = "5b92da63b66b4c29c1fca31f023363e90936330ea919418a240bab1f69517ae0";
        }
        {
          name = "glassit";
          publisher = "s-nlf-fh";
          version = "0.2.6";
          sha256 = "2dc0289a02bdd619c95aa016e08d050204cec2bf0ac2fed986f182824a242ae6";
        }
      ];
    })
    (discord.override {
      withOpenASAR = true;
      withVencord = false;
    })
    gtranslator
    impression
    spotify
    eza
    onlyoffice-bin
    gcc
    gdb
    apostrophe
    gnome-solanum
    hyperfine
    ffmpeg
    gnumake
    file
    python3
    btop
    cmake
    mission-center
    easyeffects
    gimp
    helix
    go
    gopls
    delve
    go-tools
    jetbrains.goland
    zig
    zls
    sops
    errands
    jq
  ]);

  # Install fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraCode" "Meslo" ]; })
  ];

  # Setup input method
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ mozc ];
  };
  environment.sessionVariables.MOZC_IBUS_CANDIDATE_WINDOW = "ibus";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # services.ollama = {
  #   enable = true;
  #   acceleration = "cuda";
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
