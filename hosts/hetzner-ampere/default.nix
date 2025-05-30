{ modulesPath, lib, pkgs, inputs, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [(final: prev: { botsu = prev.callPackage ../../pkgs/botsu.nix { }; })];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.helix
    pkgs.botsu
  ];

  users.users.luisl = {
    isNormalUser = true;
    home = "/home/luisl";
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [    
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4lxvIxjiF2WwXKeayBDjzLNBsB3mQ2hOS5d519ysbo"
    ];
  };
  
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "luisl" = import ./home.nix;
    };
  };

  users.users.botsu = {
    isSystemUser = true;
    description = "Service account for botsu";
    home = "/var/lib/botsu";
    group = "botsu";
    createHome = true;
  };

  users.groups.botsu = { };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;     
    dataDir = "/var/lib/postgresql/16";
    ensureDatabases = [ "botsu" ];
    ensureUsers = [
      {
        name = "botsu";
        ensureDBOwnership = true;
      }
    ];
  };

  systemd.services.botsu = {
    description = "Botsu application service";
    after = [ "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "botsu";
      WorkingDirectory = "/var/lib/botsu";
      ExecStart = "${pkgs.botsu}/bin/botsu";
      Restart = "on-failure";
      Environment = [
        "BOTSU_CONNECTION_STRING=postgresql:///botsu?host=/run/postgresql"
      ];
    };
  };

  system.stateVersion = "24.05";
}
