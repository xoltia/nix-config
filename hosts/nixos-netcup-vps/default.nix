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

  users.mutableUsers = false;

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

  boot.initrd.enable = true;
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /btrfs_tmp
    mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp

    delete_subvolume_recursively() {
      local target="$1"

      if [ ! -e "$target" ]; then
        return 0
      fi

      echo "Starting recursive deletion for: $target"

      btrfs subvolume list -o "$target" | awk '{print $NF}' | sort -r | while read -r subvol; do
        echo "Deleting nested child subvolume: /btrfs_tmp/$subvol"
        btrfs subvolume delete "/btrfs_tmp/$subvol"
      done

      echo "Deleting parent subvolume: $target"
      btrfs subvolume delete "$target"
    }

    if [ -e /btrfs_tmp/root ]; then
      delete_subvolume_recursively "/btrfs_tmp/root"
    fi

    echo "Creating blank Btrfs root subvolume..."
    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/persist".neededForBoot = true;

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/fail2ban"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.luisl = {
      directories = [
        ".ssh"
        "nix-config"
      ];
    };
  };

  services.btrfs.autoScrub.enable = true;
  system.stateVersion = "25.11";
}
