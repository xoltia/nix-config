{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.services.botsu;
in
{
  options.services.botsu = {
    enable = mkEnableOption "Whether to enable Botsu bot service.";
    tokenFile = mkOption {
      type = types.path;
      default = "";
      description = "Path to file containing the bot's Discord token (must be readable by 'botsu' user).";
    };
    youtubeKeyFile = mkOption {
      type = types.path;
      default = "";
      description = "Path to file containing the YouTube API key (must be readable by 'botsu' user).";
    };
    enableOshiStats = mkEnableOption "Whether to enable OshiStats web service.";
    oshiStatsYoutubeKeyFile = mkOption {
      type = types.path;
      default = cfg.youtubeKeyFile;
      description = "YouTube API key file used for OshiStats service.";
    };
    oshiStatsImgproxyHost = mkOption {
      type = types.str;
      description = "Imgproxy host.";
    };
    oshiStatsImgproxyKeyFile = mkOption {
      type = types.path;
      description = "Imgproxy key file.";
    };
    oshiStatsImgproxySaltFile = mkOption {
      type = types.path;
      description = "Imgproxy salt file.";
    };
    oshiStatsOauthClientSecretFile = mkOption {
      type = types.path;
      description = "Discord OAuth client secret file."
    };
    oshiStatsOauthClientId = mkOption {
      type = types.str;
      description = "Discord OAuth client ID.";
    };
    oshiStatsAddr = mkOption {
      type = types.str;
      default = ":8080";
      description = "Address to bind server.";
    };
    oshiStatsIndexerCalender = mkOption {
      type = types.str;
      default = "hourly";
      description = "Systemd timer calender string for running the indexer process.";
    };
    oshiStatsUpdaterCalender = mkOption {
      type = types.str;
      default = "weekly";
      description = "Systemd timer calender string for running the updater process.";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        botsu = prev.callPackage ../pkgs/botsu.nix { };
        botsu-oshi-stats = prev.callPackage ../pkgs/botsu-oshi-stats.nix { };
      })
    ];

    environment.systemPackages = [ pkgs.botsu pkgs.botsu-oshi-stats ];
  
    users.users.botsu = {
      isSystemUser = true;
      description = "Service account for botsu";
      home = "/var/lib/botsu";
      group = "botsu";
      createHome = true;
    };

    users.groups.botsu = { };

    services.postgresql = {
      enable = mkDefault true;
      ensureDatabases = [ "botsu" ];
      ensureUsers = [
        {
          name = "botsu";
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.botsu = {
      description = "Botsu application service";
      after = [ "network-online.target" "postgresql.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        export BOTSU_CONNECTION_STRING=postgresql:///botsu?host=/run/postgresql
        export BOTSU_TOKEN=$(cat ${cfg.tokenFile})
        export BOTSU_GOOGLE_API_KEY=$(cat ${cfg.youtubeKeyFile})
        export BOTSU_USE_MEMBERS_INTENT=1
        ${pkgs.botsu}/bin/botsu
      '';
      serviceConfig = {
        User = "botsu";
        WorkingDirectory = "/var/lib/botsu";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.services.botsu-oshi-stats-updater = mkIf cfg.enableOshiStats {
      description = "Botsu OshiStats data updater service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        export BOTSU_GOOGLE_API_KEY=$(cat ${cfg.oshiStatsYoutubeKeyFile})
        ${pkgs.botsu-oshi-stats}/bin/updater -google-api-key=$BOTSU_GOOGLE_API_KEY
      '';
      serviceConfig = {
        User = "botsu";
        Type = "oneshot";
        WorkingDirectory = "/var/lib/botsu";
        Restart = "on-failure";
      };
    };

    systemd.services.botsu-oshi-stats-indexer = mkIf cfg.enableOshiStats {
      description = "Botsu OshiStats indexer service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" "botsu.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "botsu";
        Type = "oneshot";
        Exec = "${pkgs.botsu-oshi-stats}/bin/indexer -db-url=postgresql:///botsu?host=/run/postgresql";
        WorkingDirectory = "/var/lib/botsu";
        Restart = "on-failure";
      };
    };

    systemd.services.botsu-oshi-stats-server = mkIf cfg.enableOshiStats {
      description = "Botsu OshiStats website server service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.botsu}/bin/server \
          -addr="${cfg.oshiStatsAddr}" \
          -oauth-client-id="${cfg.oshiStatsOauthClientId}" \
          -oauth-client-secret="$(cat ${cfg.oshiStatsOauthClientSecretFile})" \
          -imgproxy-host="${cfg.oshiStatsImgproxyHost}" \
          -imgproxy-salt="$(cat ${cfg.oshiStatsImgproxySaltFile})" \
          -imgproxy-key="$(cat ${cfg.oshiStatsImgproxyKeyFile})"
      '';
      serviceConfig = {
        User = "botsu";
        WorkingDirectory = "/var/lib/botsu";
        Restart = "on-failure";
      };
    };

    systemd.timers.botsu-oshi-stats-indexer = mkIf cfg.enableOshiStats {
      wantedBy = [ "timers.target" ];
      partOf = [ "botsu-oshi-stats-indexer.service" ];
      timerConfig = {
        OnCalendar = cfg.oshiStatsIndexerCalender;
        Persistent = true;
      };
    };

    systemd.timers.botsu-oshi-stats-updater = mkIf cfg.enableOshiStats {
      wantedBy = [ "timers.target" ];
      partOf = [ "botsu-oshi-stats-indexer.service" ];
      timerConfig = {
        OnCalendar = cfg.oshiStatsIndexerCalender;
        Persistent = true;
      };
    };
  };
}
