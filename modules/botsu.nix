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
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        botsu = prev.callPackage ../pkgs/botsu.nix { };
      })
    ];

    environment.systemPackages = [ pkgs.botsu ];
  
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
  };
}
