{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tududi;
in
{
  options.services.tududi = {
    enable = mkEnableOption "Tududi service";

    user = mkOption {
      type = types.str;
      default = "tududi";
    };

    group = mkOption {
      type = types.str;
      default = "tududi";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/tududi";
    };

    port = mkOption {
      type = types.port;
      default = 3002;
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      home = cfg.dataDir;
      createHome = true;
      group = cfg.group;
      linger = true;
      autoSubUidGidRange = true;
    };

    users.groups.${cfg.group} = { };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0770 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/db 0770 ${cfg.user} ${cfg.group} -"
      "d ${cfg.dataDir}/uploads 0770 ${cfg.user} ${cfg.group} -"
    ];

    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers.tududi = {
      image = "chrisvel/tududi:0.89.0";
      autoStart = true;
      environment = {
        APP_UID = "0";
        APP_GID = "0";
      };
      environmentFiles = lib.optionals
        (cfg.environmentFile != null)
        [ cfg.environmentFile ];
      ports = [ "${toString cfg.port}:3002" ];
      volumes = [
        "${cfg.dataDir}/db:/app/backend/db"
        "${cfg.dataDir}/uploads:/app/backend/uploads"
      ];
      podman.user = cfg.user;
    };
  };
}
