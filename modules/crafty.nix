{ config, pkgs, lib, ... }:

let
  cfg = config.services.crafty;
in
{
  options.services.crafty = {      
    enable = mkEnableOption "Crafty Controller service";

    user = mkOption {
      type = types.str;
      default = "crafty";
    };

    group = mkOption {
      type = types.str;
      default = "crafty";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/crafty";
    };

    dashboardPort = mkOption {
      type = types.port;
      default = 3002;
    };

    openDashboardPort = mkOption {
      type = types.bool;
      default = false;
      description = "Open the dashboard port in the firewall.";
    };
    
    openBedrockPort = mkOption {
      type = types.bool;
      default = false;
      description = "Open the Bedrock server port in the firewall.";
    };
    
    openJavaPorts = mkOption {
      type = types.bool;
      default = false;
      description = "Open the Java server ports in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    users.users.${cfg.user} = {
      isSystemUser = true;
      autoSubUidGidRange = true;
      group = cfg.group;
      home = cfg.dataDir;
      linger = true;
    };

    users.groups.${cfg.group} = {};

    # Ensure directories exist
    systemd.tmpfiles.rules = [
      "d ${dataDir} 0770 ${cfg.user} ${cfg.group} -"
      "d ${dataDir}/backups 0770 ${cfg.user} ${cfg.group} -"
      "d ${dataDir}/logs 0770 ${cfg.user} ${cfg.group} -"
      "d ${dataDir}/servers 0770 ${cfg.user} ${cfg.group} -"
      "d ${dataDir}/config 0770 ${cfg.user} ${cfg.group} -"
      "d ${dataDir}/import 0770 ${cfg.user} ${cfg.group} -"
    ];

    virtualisation.oci-containers.containers.crafty = {
      image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
      autoStart = true;
      environment = { TZ = "Etc/UTC"; };
      podman.user = cfg.user;
      ports = [
        "${cfg.dashboardPort}:8443"
        "19132:19132/udp"
        "25500-25600:25500-25600"
      ];
      volumes = [
        "${cfg.dataDir}/backups:/crafty/backups"
        "${cfg.dataDir}/logs:/crafty/logs"
        "${cfg.dataDir}/servers:/crafty/servers"
        "${cfg.dataDir}/config:/crafty/app/config"
        "${cfg.dataDir}/import:/crafty/import"
      ];
    };
  
    networking.firewall = {
      allowedUDPPorts = lib.optionals cfg.openBedrockPort [ 19132 ];
      allowedTCPPortRanges =
        (lib.optionals cfg.openJavaPorts [ { from = 25500; to = 25600; } ])
        ++ (lib.optionals cfg.openDashboardPort [ cfg.port ]);
    };
  };
}
