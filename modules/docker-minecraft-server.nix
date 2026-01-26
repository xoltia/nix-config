# TODO: Make this module configurable with options?
{ pkgs, config, ... }:
{
  sops.secrets."curseforge_api_key".mode = "0400";
  sops.secrets."curseforge_api_key".owner = "luisl";

  systemd.tmpfiles.rules = [
    "d /home/luisl/mnt/mcbackups 0770 luisl - -"
    "d /home/luisl/minecraft-server/atm10 0770 luisl - -"
  ];

  virtualisation.oci-containers.containers.atm10-mc-server =
  let
    simplebackupsCfg = pkgs.writeTextFile {
      name = "atm10-mc-server-simplebackups-config";
      text =
      # toml
      ''
        enabled = true
        backupType = "FULL_BACKUPS"
        saveAll = true
        fullBackupTimer = 525960
        backupsToKeep = 20
        timer = 240
        compressionLevel = -1
        sendMessages = true
        maxDiskSize = "100 GB"
        outputPath = "/backups"
        noPlayerBackups = false
        createSubDirs = true
        useTickCounter = false
        [to_ignore]
        ignored_paths = []
        ignored_files = []
        ignored_files_regex = ""
        [mod_compat]
        mc2discord = true
      '';
    };
  in
  {
    image = "itzg/minecraft-server";
    ports = [ "0.0.0.0:25565:25565" ];
    environment = {
      EULA = "TRUE";
      CF_API_KEY_FILE = "/run/secrets/cf_api_key";
      CF_SLUG = "all-the-mods-10";
      CF_EXCLUDE_MODS = "colorwheel,colorwheel-patcher";
      TYPE = "AUTO_CURSEFORGE";
      INIT_MEMORY="2G";
      MAX_MEMORY="14G";
      OPS = "62d51e49-4a49-46eb-884d-4fd60200283b";
      SYNC_SKIP_NEWER_IN_DESTINATION = "false";
    };
    volumes = [
      "/home/luisl/minecraft-server/atm10:/data"
      "/home/luisl/mnt/mcbackups:/backups"
      "${simplebackupsCfg}:/config/simplebackups-common.toml"
      (config.sops.secrets.curseforge_api_key.path + ":/run/secrets/cf_api_key")
    ];
  };

  systemd.services.rclone-mount-mcbackup = {
    description = "Rclone mount for mcbackup bucket";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    requiredBy = [ (config.virtualisation.oci-containers.containers.atm10-mc-server.serviceName + ".service") ];
    before = [ (config.virtualisation.oci-containers.containers.atm10-mc-server.serviceName + ".service") ];
    serviceConfig = {
      Type = "notify";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          "mega-s4:mcbackup" \
          /home/luisl/mnt/mcbackups \
          --config=''${CREDENTIALS_DIRECTORY}/rclone.conf \
          --uid=1000 \
          --allow-other \
          --umask=077
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u /home/luisl/mnt/mcbackups";
      Restart = "on-failure";
      RestartSec = "10s";
      LoadCredential = [ ("rclone.conf:" + config.sops.secrets."rclone/mega-s4-amsterdam".path) ];
    };
  };
}
