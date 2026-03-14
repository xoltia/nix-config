{ pkgs, config, lib, ... }:

with lib;
let
    cfg = config.services.dockerMinecraftServer;
in
{
  options.services.dockerMinecraftServer = {
    eula = mkOption {
      type = types.bool;
      default = false;
    };

    baseDir = mkOption {
      type = types.path;
      default = "/var/lib/docker-minecraft-server";
    };

    instances = mkOption {
      default = {};
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };

          imageTag = mkOption {
            type = types.str;
            default = "latest";
          };

          port = mkOption {
            type = types.port;
            default = 25565;
          };

          cfModpackSlug = mkOption {
            type = types.str;
            default = "";
            example = "all-the-mods-10";
          };

          cfApiKeyFile = mkOption {
            type = types.nullOr types.path;
            default = null;
          };

          memoryMin = mkOption {
            type = types.str;
            default = "2G";
          };

          memoryMax = mkOption {
            type = types.str;
            default = "8G";
          };          

          ops = mkOption {
            type = types.listOf types.str;
            default = [ ];
          };

          dataDir = mkOption {
            type = types.path;
            default = "${cfg.baseDir}/${name}/data";
          };

          backupsDir = mkOption {
            type = types.path;
            default = "${cfg.baseDir}/${name}/backups";
          };

          enableBackups = mkOption {
            type = types.bool;
            default = true;
          };

          extraOptions = mkOption {
            type = types.attrsOf types.str;
            default = { };
          };

          extraBackupOptions = mkOption {
            type = types.attrsOf types.str;
            default = { };
          };
        };
      }));
    };
  };

  config =
    let
      safeNameRegex = "^[a-z][a-z0-9-]*[a-z0-9]$";
      podName = name: "dockerMinecraftServer-podman-pod-${name}";

      makeServerContainer = name: opts:
        nameValuePair "mc-${name}" {
          image = "itzg/minecraft-server:${opts.imageTag}";
          # ports = [
          #   "0.0.0.0:${toString opts.port}:25565"
          # ];
          podman.user = "mc-${name}";

          environment = {
            EULA = "TRUE";
            UID = "0";
            GID = "0";
            TYPE = if opts.cfModpackSlug != "" then "AUTO_CURSEFORGE" else "";
            CF_SLUG = opts.cfModpackSlug;
            CF_API_KEY_FILE = if opts.cfApiKeyFile != null then "/cf_api_key" else "";
            INIT_MEMORY = opts.memoryMin;
            MAX_MEMORY = opts.memoryMax;
            OPS = strings.concatStringsSep "," opts.ops;
          } // opts.extraOptions;

          volumes = [
            "${opts.dataDir}:/data"
          ] ++ optionals (opts.cfApiKeyFile != null) [
            "${opts.cfApiKeyFile}:/cf_api_key:ro"
          ];

          extraOptions = [ "--pod=${podName name}" ];
        };

      makeBackupContainer = name: opts:
        nameValuePair "mc-${name}-backup" {
          image = "itzg/mc-backup";
          podman.user = "mc-${name}";
          environment = opts.extraBackupOptions;
          volumes = [
            "${opts.dataDir}:/data:ro"
            "${opts.backupsDir}:/backups"
          ];
          extraOptions = [ "--pod=${podName name}" ];
        };

      serverContainers =         
        mapAttrs'
          makeServerContainer
          (filterAttrs (_: v: v.enable) cfg.instances);

      backupContainers = 
        mapAttrs'
          makeBackupContainer
          (filterAttrs (_: v: v.enable && v.enableBackups) cfg.instances);

      enabledInstances =
        filterAttrs (_: v: v.enable) cfg.instances;
    in
    {
      assertions = [
        {
          assertion = cfg.eula || ((filterAttrs (_: v: v.enable) cfg.instances) == {});
          message = "Must accept the EULA before enabling instances";
        }
      ] ++
      mapAttrsToList
        (name: _:
          {
            assertion = builtins.match safeNameRegex name != null;
            message = "Invalid minecraft instance name `${name}`";
          })
        cfg.instances;

      users.users =
        mapAttrs'
          (name: _:
            nameValuePair "mc-${name}" {
              isSystemUser = true;
              group = "mc-${name}";
              home = "${cfg.baseDir}/${name}";
              createHome = true;
              linger = true;
              autoSubUidGidRange = true;
            })
          enabledInstances;

      users.groups =
        mapAttrs'
          (name: _: nameValuePair "mc-${name}" {})
          enabledInstances;

      systemd.tmpfiles.rules =
            flatten (mapAttrsToList
              (name: _:
                let
                  root = "${cfg.baseDir}/${name}";
                in [
                  "d ${root} 0750 mc-${name} mc-${name} -"
                  "d ${root}/data 0750 mc-${name} mc-${name} -"
                  "d ${root}/backups 0750 mc-${name} mc-${name} -"
                ])
              enabledInstances);

      virtualisation.oci-containers.containers =
        serverContainers // backupContainers;

      systemd.services =
        let
          ensurePod = name: port:
            pkgs.writeShellScript "ensure-pod" ''
              set -euo pipefail

                if ! ${getExe pkgs.podman} pod exists ${podName name}; then
                  ${getExe pkgs.podman} pod create \
                    --name ${podName name} \
                    --publish 0.0.0.0:${toString port}:25565
                fi
            '';
        in
        # TODO: make this a single service that makes all networks and removes unused ones.
        (mapAttrs'
          (name: { port, ... }: nameValuePair (podName name) {
            description = "Ensures Podman pod for docker-minecraft-server instance '${name}' exists";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              User = "mc-${name}";
              Group = "mc-${name}";
              ExecStart = (ensurePod name port);
            };
          })
          enabledInstances) //
        (mapAttrs'
          (name: _: nameValuePair "podman-${name}" {
            after = [ "${podName name}.service" ];
            requires = [ "${podName name}.service" ];
          })
          enabledInstances) //        
        (mapAttrs'
          (name: _: nameValuePair "podman-${name}-backup" {
            after = [ "${podName name}.service" ];
            requires = [ "${podName name}.service" ];
          })
          enabledInstances);
    };
}
