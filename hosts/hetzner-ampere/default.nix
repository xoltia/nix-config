{ modulesPath, lib, pkgs, inputs, config, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/services/backup/postgresql-backup.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/botsu.nix
    ../../modules/imgproxy.nix
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.helix
  ];


  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.openssh.enable = true;
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

  sops.secrets."botsu/discord_token".owner = config.users.users.botsu.name;
  sops.secrets."botsu/youtube_api_key".owner = config.users.users.botsu.name;
  sops.secrets."botsu/discord_token".restartUnits = [ "botsu.service" ];
  sops.secrets."botsu/youtube_api_key".restartUnits = [ "botsu.service" ];
  
  sops.secrets."imgproxy/key".owner = config.users.users.imgproxy.name;
  sops.secrets."imgproxy/salt".owner = config.users.users.imgproxy.name;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;     
    dataDir = "/var/lib/postgresql/16";
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "botsu" ];
    compression = "gzip";
  };

  services.botsu = {
    enable = true;
    tokenFile = config.sops.secrets."botsu/discord_token".path;
    youtubeKeyFile = config.sops.secrets."botsu/youtube_api_key".path;
  };

  services.imgproxy = {
    enable = true;
    keyFile = config.sops.secrets."imgproxy/key".path;
    saltFile = config.sops.secrets."imgproxy/salt".path;
    bindAddr = "127.0.0.1:5300";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;

    virtualHosts."jllamas.dev" = {
      addSSL = true;
      enableACME = true;
      globalRedirect = "xoltia.github.io";
    };

    virtualHosts."www.jllamas.dev" = {
      addSSL = true;
      enableACME = true;
      globalRedirect = "jllamas.dev";
    };

    virtualHosts."imgproxy.jllamas.dev" = {
      addSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5300";
        extraConfig = ''
          add_header Access-Control-Allow-Origin *;
          proxy_cache imgproxy_cache;
          proxy_cache_valid 200 7d;
          proxy_cache_valid 404 1h;
        '';
      };
    };

    proxyCachePath.imgproxy-cache = {
      enable = true;
      keysZoneName = "imgproxy_cache";
      inactive = "1d";
      maxSize = "1g";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "llamas.jnl@gmail.com";
  };

  system.stateVersion = "24.05";
}
