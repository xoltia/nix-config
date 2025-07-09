{ modulesPath, lib, pkgs, inputs, config, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/botsu.nix
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.helix
  ];

  programs.zsh.enable = true;
  users.users.luisl = {
    isNormalUser = true;
    home = "/home/luisl";
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [    
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4lxvIxjiF2WwXKeayBDjzLNBsB3mQ2hOS5d519ysbo luisl@nixos"
    ];
    shell = pkgs.zsh;
  };
  
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "luisl" = import ./home.nix;
    };
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/luisl/.config/sops/age/keys.txt";

  sops.secrets."botsu/discord_token".owner = "botsu";
  sops.secrets."botsu/youtube_api_key".owner = "botsu";
  sops.secrets."botsu/discord_token".restartUnits = [ "botsu.service" ];
  sops.secrets."botsu/youtube_api_key".restartUnits = [ "botsu.service" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;     
    dataDir = "/var/lib/postgresql/16";
  };

  services.botsu = {
    enable = true;
    tokenFile = config.sops.secrets."botsu/discord_token".path;
    youtubeKeyFile = config.sops.secrets."botsu/youtube_api_key".path;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;
    virtualHosts."jllamas.dev" = {
      addSSL = true;
      enableACME = true;
      globalRedirect = "xoltia.github.io";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "llamas.jnl@gmail.com";
  };

  system.stateVersion = "24.05";
}
