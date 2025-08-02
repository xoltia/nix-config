# This service provides additional functionality to the `postgresqlBackup` service by
# allowing for automatic archival to a remote source using rclone. Currently this only
# works with databases explicitly listed in `services.postgresqlBackup.databases`,
# and does not work when using `services.postgresqlBackup.backupAll`.
{ config, pkgs, lib, ... }:
let
  cfg = config.services.postgresqlBackupArchive;
  backupCfg = config.services.postgresqlBackup;
  archiveScript = dbName:
    pkgs.writeShellScriptBin "pg-db-archive" ''
      localPath="${backupCfg.location}/${dbName}${cfg.backupSuffix}"
      remotePath="${dbName}_$(date --utc +%Y-%m-%dT%H-%M-%SZ)${cfg.backupSuffix}"
      ${pkgs.rclone}/bin/rclone \
        --config "$CREDENTIALS_DIRECTORY/rclone-config" \
        copyto "''${localPath}" "${cfg.rcloneRemote}/''${remotePath}"
    '';
in
{
  options.services.postgresqlBackupArchive = with lib; {
    databases = mkOption {
      type = types.listOf types.str; 
      default = [ ];
    };
    rcloneConfigFile = mkOption {
      type = types.path;
      default = "";
    };
    rcloneRemote = mkOption {
      type = types.str;
      default = "";
      example = "my-remote:bucket";
    };
    backupSuffix = mkOption {
      type = types.str;
      default = ".sql" + (
        let c = backupCfg.compression; in
          if c == "zstd" then
            ".zstd"
          else if c == "gzip" then
            ".gz"
          else
            ""
      );
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.rcloneConfigFile != "" && cfg.rcloneRemote != "";
        message = "rcloneConfigFile and rcloneRemote must be specified";
      }
    ] ++ (
      map (db:
        {
          assertion = builtins.elem db backupCfg.databases;
          message = db + " is not present in backup databases";
        }
      )
      cfg.databases
    );
    
    systemd.services = lib.listToAttrs (
      map (db:
        let
          script = archiveScript db;
        in
        {
          # This is the unit created by the posgresqlBackup service.
          name = "postgresqlBackup-${db}";
          value = {
            serviceConfig = {
              ExecStartPost = [ "${script}/bin/pg-db-archive" ];
              LoadCredential = [ "rclone-config:${cfg.rcloneConfigFile}" ];
            };
          };
        }
      ) cfg.databases
    );
  };
}
