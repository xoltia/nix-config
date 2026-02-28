{ pkgs, config, lib, ... }:
{
  environment.systemPackages = [
    pkgs.gokapi
  ];
  
  # sops.secrets."gokapi/env" = { };
  sops.secrets."gokapi/cloudconfig" = { };
  sops.secrets."gokapi/deployment_password" = { };

  systemd.services.gokapi = {
    wantedBy = [ "default.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment = {
      GOKAPI_CONFIG_DIR = "%S/gokapi/config";
      GOKAPI_CONFIG_FILE = "config.json";
      GOKAPI_DATA_DIR = "%S/gokapi/data";
    };
    unitConfig = {
      Description = "gokapi service";
    };
    serviceConfig = {
      ExecStartPre =
        let
          settingsFile = pkgs.writeText "config.json" ''
            {
              "Authentication": {
                "Method": 0,
                "Username": "luisl",
                "HeaderKey": "",
                "OauthProvider": "",
                "OAuthClientId": "",
                "OAuthClientSecret": "",
                "OauthGroupScope": "",
                "OAuthRecheckInterval": 12,
                "OAuthGroups": [],
                "OnlyRegisteredUsers": false
              },
              "Port": ":53842",
              "ServerUrl": "https://gokapi.jllamas.dev/",
              "RedirectUrl": "https://github.com/Forceu/Gokapi/",
              "PublicName": "Gokapi",
              "DataDir": "/var/lib/gokapi/data",
              "DatabaseUrl": "sqlite:///var/lib/gokapi/data/gokapi.sqlite",
              "ConfigVersion": 22,
              "MaxFileSizeMB": 102400,
              "MaxMemory": 50,
              "ChunkSize": 45,
              "MaxParallelUploads": 4,
              "Encryption": {
                "Level": 0,
                "Cipher": null,
                "Salt": "",
                "Checksum": "",
                "ChecksumSalt": ""
              },
              "UseSsl": false,
              "PicturesAlwaysLocal": false,
              "SaveIp": false,
              "IncludeFilename": false
            }
          '';
          updateScript = lib.getExe (
            pkgs.writeShellApplication {
              name = "write-config";
              text = ''
                configFile="$1"
                statefulConfigFile="$2"
                deploymentPasswordFile="$3"
                cloudConfigFile="$4"
                statefulCloudConfigFile="$5"
                mkdir -p "$(dirname "$statefulConfigFile")"
                cat "$configFile" > "$statefulConfigFile"
                cat "$cloudConfigFile" > "$statefulCloudConfigFile"
                ${lib.getExe pkgs.gokapi} --deployment-password "$(cat "$deploymentPasswordFile")"
              '';
            }
          );
        in
        lib.strings.concatStringsSep " " [
          updateScript
          settingsFile
          "%S/gokapi/config/config.json"
          "%d/deployment-password"
          # config.sops.secrets."gokapi/cloudconfig".path
          "%d/cloudconfig"
          "%S/gokapi/config/cloudconfig.yml"
        ];
      ExecStart = lib.getExe pkgs.gokapi;
      # EnvironmentFile = config.sops.secrets."gokapi/env".path;
      LoadCredential = [
        "deployment-password:${config.sops.secrets."gokapi/deployment_password".path}"
        "cloudconfig:${config.sops.secrets."gokapi/cloudconfig".path}"
      ];
      RestartSec = 30;
      DynamicUser = true;
      PrivateTmp = true;
      StateDirectory = "gokapi";
      CacheDirectory = "gokapi";
      Restart = "on-failure";
    };
  };
}
