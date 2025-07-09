{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.services.imgproxy;
  addImgproxyPrefix = attrs: builtins.listToAttrs (
    builtins.map (key: {
      name = "IMGPROXY_${key}";
      value = attrs.${key};
    }) (builtins.attrNames attrs)
  );
in
{
  options.services.imgproxy = {
    enable = mkEnableOption "Whether to enable the imgproxy service.";
    bindAddr = mkOption {
      type = types.str;
      default = ":8080";
      description = "The port or socket to listen on.";
    };
    saltFile = mkOption {
      type = types.path;
      description = "Path to salt file used for signing.";
    };
    keyFile = mkOption {
      type = types.path;
      description = "Path to key file used for signing.";
    };
    extraConfig = mkOption {
      type =
        with types;
        attrsOf (
          nullOr (oneOf [
            str
            path
            package
          ])
        );
      default = { };
      example = {
        TIMEOUT = "20";
        WORKERS = "1";
      };
      description = "Extra configuration passed as environment variables.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.imgproxy ];

    users.users.imgproxy = {
      isSystemUser = true;
      description = "Service account for imgproxy";
      home = "/var/lib/imgproxy";
      group = "imgproxy";
      createHome = true;
    };

    users.groups.imgproxy = { };
    
    systemd.services.imgproxy = {
      description = "Imgproxy server service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      environment =
        let
          baseConfig = { BIND = cfg.bindAddr; };
        in
          addImgproxyPrefix (baseConfig // cfg.extraConfig);
      serviceConfig = {
        User = "imgproxy";
        Group = "imgproxy";
        ExecStart = "${pkgs.imgproxy}/bin/imgproxy -saltpath=${cfg.saltFile} -keypath=${cfg.keyFile}";
        Restart = "always";
      };
    };
  };
}
