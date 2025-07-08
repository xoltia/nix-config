{ pkgs, ... }:

with lib;
let
  cfg = config.services.botsu;
{
  options.services.botsu = {
    enable = mkEnableOption "Whether to enable Botsu bot service.";
    tokenFile = mkOption {
      type = "path";
      default = "";
      description = "Path to file containing the bot's Discord token (must be readable by 'botsu' user).";
    };
    youtubeKeyFile = mkOption {
      type = "path";
      default = "";
      description = "Path to file containing the YouTube API key (must be readable by 'botsu' user).";
    };
  };

  config.nixpkgs.overlays = [
    (final: prev: {
      botsu = prev.callPackage ../pkgs/botsu.nix { };
    })
  ];

  config = mkIf cfg.enable {
    system.environmentPackages = [ pkgs.botsu ];
  
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
      after = [ "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        export BOTSU_CONNECTION_STRING=postgresql:///botsu?host=/run/postgresql
        export BOTSU_TOKEN=$(cat ${cfg.tokenFile})
        export BOTSU_GOOGLE_API_KEY=$(cat ${cfg.youtubeKeyFile})
      '';
      serviceConfig = {
        User = "botsu";
        WorkingDirectory = "/var/lib/botsu";
        ExecStart = "${pkgs.botsu}/bin/botsu";
        Restart = "on-failure";
      };
    };
  };
}
