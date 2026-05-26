{ modulesPath, lib, pkgs, config, inputs, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.grub = {
    devices = [ "/dev/vda" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "nixos-netcup-vps";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.fail2ban.enable = true;
  programs.zsh.enable = true;
  
  sops = {
    defaultSopsFile = ../../secrets/host-nixos-netcup-vps.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  sops.secrets."users/luisl/password" = {
    neededForUsers = true;
  };

  users.users.luisl = {
    isNormalUser = true;
    home = "/home/luisl";
    extraGroups  = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets."users/luisl/password".path;
    openssh.authorizedKeys.keys =
      let
        sshKeys = import ../../modules/ssh-keys.nix { inherit lib; };
      in [
        sshKeys."luisl@win".raw
        sshKeys."luisl@nixos-desktop".raw
        sshKeys."nixos@nixos-wsl".raw
      ];
    shell = pkgs.zsh;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "luisl" = import ./home.nix;
    };
  };

  services.btrfs.autoScrub.enable = true;
  system.stateVersion = "25.11";
}
