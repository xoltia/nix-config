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
    ../../modules/postgresql-backup-archive.nix
    # ../../modules/docker-minecraft-server.nix
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
    pkgs.tmux
  ];

  networking.hostName = "nixos-hetzner-vps";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.openssh.enable = true;
  programs.zsh.enable = true;

  users.users.luisl = {
    isNormalUser = true;
    home = "/home/luisl";
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [    
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4lxvIxjiF2WwXKeayBDjzLNBsB3mQ2hOS5d519ysbo luisl@nixos-desktop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzk3lPhMjqFh23XReBtVy5lIdXj6js8NSLYvpLIkPIe nixos@nixos-wsl"
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

  # Secrets for running the Botsu Discord bot
  sops.secrets."botsu/discord_token".owner = config.users.users.botsu.name;
  sops.secrets."botsu/youtube_api_key".owner = config.users.users.botsu.name;
  sops.secrets."botsu/oshi_stats_oauth_secret".owner = config.users.users.botsu.name;
  sops.secrets."botsu/discord_token".restartUnits = [ "botsu.service" ];
  sops.secrets."botsu/youtube_api_key".restartUnits = [ "botsu.service" ];
  sops.secrets."botsu/oshi_stats_oauth_secret".restartUnits = [ "botsu-oshi-stats-server.service" ];

  # Secrets for running improxy service
  sops.secrets."imgproxy/key".owner = config.users.users.imgproxy.name;
  sops.secrets."imgproxy/salt".owner = config.users.users.imgproxy.name;

  sops.secrets.botsu-imgproxy-key.owner = config.users.users.botsu.name;
  sops.secrets.botsu-imgproxy-salt.owner = config.users.users.botsu.name;
  sops.secrets.botsu-imgproxy-key.key = "imgproxy/key";
  sops.secrets.botsu-imgproxy-salt.key = "imgproxy/salt";

  # currently used for postgres archival and minecraft server backups
  sops.secrets."rclone/mega-s4-amsterdam" = { };
  sops.secrets."rclone/hetzner-storagebox" = { };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;     
    dataDir = "/var/lib/postgresql/16";
  };

  services.postgresqlBackup = {
    enable = true;
    databases = [ "botsu" ];
    compression = "zstd";
    compressionLevel = 19;
  };

  services.postgresqlBackupArchive = {
    # rcloneConfigFile = config.sops.secrets."rclone/mega-s4-amsterdam".path;
    # rcloneRemote = "mega-s4:pgarchive";
    rcloneConfigFile = config.sops.secrets."rclone/hetzner-storagebox".path;
    rcloneRemote = "hetzner-storagebox:pgarchive";
    databases = [ "botsu" ];
  };

  services.botsu = {
    enable = true;
    enableOshiStats = false;
    tokenFile = config.sops.secrets."botsu/discord_token".path;
    youtubeKeyFile = config.sops.secrets."botsu/youtube_api_key".path;
    oshiStatsAddr = "127.0.0.1:5301";
    oshiStatsOauthRedirect = "https://oshistats.jllamas.dev/auth/callback";
    oshiStatsOauthClientId = "1391866556929278024";
    oshiStatsOauthClientSecretFile = config.sops.secrets."botsu/oshi_stats_oauth_secret".path;
    oshiStatsImgproxyHost = "imgproxy.jllamas.dev";
    oshiStatsImgproxySaltFile = config.sops.secrets.botsu-imgproxy-salt.path;
    oshiStatsImgproxyKeyFile = config.sops.secrets.botsu-imgproxy-key.path;
  };

  services.imgproxy = {
    enable = true;
    keyFile = config.sops.secrets."imgproxy/key".path;
    saltFile = config.sops.secrets."imgproxy/salt".path;
    bindAddr = "127.0.0.1:5300";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 25565 ];

  services.nginx = {
    enable = true;
    recommendedBrotliSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

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

    virtualHosts."oshistats.jllamas.dev" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://127.0.0.1:5301";
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
          proxy_cache_valid 404 1m;
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
