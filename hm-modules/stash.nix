{ pkgs, ... }:

{
  home.packages = [ pkgs.stash ];

  systemd.user.services.stashapp = {
    Unit = {
      Description = "Stash app service.";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${pkgs.stash}/bin/stash --nobrowser";
      Restart = "always";
    };
  };
}

