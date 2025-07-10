{ config, pkgs, lib, ... }:
let
  cfg = config.services.postgresqlBackupArchive;
  archiveScript = dbName:
    pkgs.writeShellScriptBin "pg-db-archive" ''
      dirBackup="${config.services.postgresqlBackup.location}"
      fileBackup="''${dirBackup}/${dbName}${cfg.backupSuffix}"
      fileArchive="${dbName}_$(date --utc +%Y-%m-%dT%H-%M-%SZ)${cfg.backupSuffix}"
      ${pkgs.rclone}/bin/rclone \
        --config "$CREDENTIALS_DIRECTORY/rclone-config" \
        copyto "''${fileBackup}" "${cfg.rcloneRemote}/''${fileArchive}"
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
      default = ".sql.gz";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.rcloneConfigFile != "" && cfg.rcloneRemote != "";
        message = "rcloneConfigFile and rcloneRemote must be specified";
      }
    ];
    
    systemd.services = lib.listToAttrs (
      map (db:
        let
          script = archiveScript db;
        in
        {
          name = "postgresqlBackup-${db}";
          value = {
            serviceConfig = {
              ExecStartPost = "${script}/bin/pg-db-archive";
              LoadCredential = [ "rclone-config:${cfg.rcloneConfigFile}" ];
            };
          };
        }
      ) cfg.databases
    );
  };
}
