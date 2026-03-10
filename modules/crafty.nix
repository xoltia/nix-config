{ config, pkgs, ... }:

let
  dataDir = "/var/lib/crafty";
in
{
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  users.users.crafty = {
    isSystemUser = true;
    autoSubUidGidRange = true;
    group = "crafty";
    home = dataDir;
    linger = true;
  };

  users.groups.crafty = {};

  # Ensure directories exist
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0770 crafty crafty -"
    "d ${dataDir}/backups 0770 crafty crafty -"
    "d ${dataDir}/logs 0770 crafty crafty -"
    "d ${dataDir}/servers 0770 crafty crafty -"
    "d ${dataDir}/config 0770 crafty crafty -"
    "d ${dataDir}/import 0770 crafty crafty -"
  ];

  virtualisation.oci-containers.containers.crafty = {
    image = "registry.gitlab.com/crafty-controller/crafty-4:latest";
    autoStart = true;

    environment = {
      TZ = "Etc/UTC";
    };

    ports = [
      "8443:8443"
      "8123:8123"
      "19132:19132/udp"
      "25500-25600:25500-25600"
    ];

    volumes = [
      "${dataDir}/backups:/crafty/backups"
      "${dataDir}/logs:/crafty/logs"
      "${dataDir}/servers:/crafty/servers"
      "${dataDir}/config:/crafty/app/config"
      "${dataDir}/import:/crafty/import"
    ];

    podman = {
      user = "crafty";
    };

    # extraOptions = [ "--userns=keep-id" ];
  };

  networking.firewall = {
    allowedUDPPorts = [ 19132 ];
    allowedTCPPortRanges = [ { from = 25500; to = 25600; } ];
  };
}
