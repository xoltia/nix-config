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
  ];

  networking.useDHCP = false;
  systemd.network.enable = true;
  systemd.network.networks."30-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    address = [ "2a01:4f8:c0c:446e::/64" ];
    routes = [ { Gateway = "fe80::1"; } ];
  };

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
    openssh.authorizedKeys.keys =
      let
        sshKeys = import ../../modules/ssh-keys.nix { inherit lib; };
      in
        [
          sshKeys."luisl@win".raw
          sshKeys."luisl@nixos-desktop".raw
        ];
    shell = pkgs.zsh;
  };
  
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "luisl" = import ./home.nix;
    };
  };

  sops = {
    defaultSopsFile = ../../secrets/host-nixos-hetzner-vps.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # Secrets for running the Botsu Discord bot
  sops.secrets."botsu/discord_token".owner = config.users.users.botsu.name;
  sops.secrets."botsu/youtube_api_key".owner = config.users.users.botsu.name;
  sops.secrets."botsu/oshi_stats_oauth_secret".owner = config.users.users.botsu.name;
  sops.secrets."botsu/discord_token".restartUnits = [ "botsu.service" ];
  sops.secrets."botsu/youtube_api_key".restartUnits = [ "botsu.service" ];
  sops.secrets."botsu/oshi_stats_oauth_secret".restartUnits = [ "botsu-oshi-stats-server.service" ];
  sops.secrets."rclone/botsu_postgres_backup_b2" = { };

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
    rcloneConfigFile = config.sops.secrets."rclone/botsu_posthres_backup_b2".path;
    rcloneRemote = "b2:jllamas-pgbackup-hetzner-vps";
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
    enable = false;
    keyFile = config.sops.secrets."imgproxy/key".path;
    saltFile = config.sops.secrets."imgproxy/salt".path;
    bindAddr = "127.0.0.1:5300";
  };

  services.nginx = {
    enable = true;
    recommendedBrotliSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;

    virtualHosts."jllamas.dev" = {
      enableACME = true;
      addSSL = true;
      globalRedirect = "xoltia.github.io";
    };

    virtualHosts."www.jllamas.dev" = {
      enableACME = true;
      addSSL = true;
      globalRedirect = "xoltia.github.io";
    };    
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "llamas.jnl@gmail.com";
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedTCPPorts = [ 80 443 ];
  };

  system.stateVersion = "24.05";
}
