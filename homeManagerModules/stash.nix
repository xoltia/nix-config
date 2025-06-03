{ pkgs, ... }:

{
  home.packages = [ pkgs.stash ];

  systemd.user.services.stashapp = {
    Unit.Description = "Stash app service.";
    Install.WantedBy = [ "default.target" ];
    Service.ExecStart = "${pkgs.stash}";    
  };
}

