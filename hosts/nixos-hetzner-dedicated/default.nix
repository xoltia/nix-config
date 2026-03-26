# Full NixOS configuration for a ZFS server with full disk encryption hosted on Hetzner.
# See <https://mazzo.li/posts/hetzner-zfs.html> for more information.

{ config, pkgs, lib, inputs, ... }:
let
  sshKeys = import ../../modules/ssh-keys.nix { inherit lib; };
  # Deployment-specific parameters -- you need to fill these in where the ... are
  hostName = "nixos-hetzner-dedicated";
  publicKey = sshKeys."luisl@win:initrd".noComment;
  # From `ls -lh /dev/disk/by-id`
  sda = "ata-ST4000NM0245-1Z2107_ZC14YB2D";
  sdb = "ata-ST4000NM0245-1Z2107_ZC16R0XR";
  # See <https://major.io/2015/08/21/understanding-systemds-predictable-network-device-names/#picking-the-final-name>
  # for a description on how to find out the network card name reliably.
  networkInterface = "enp0s31f6";
  # This was derived from `sudo lshw -C network`, for me it says `driver=igb`.
  # Needed to load the right driver before boot for the initrd SSH session.
  networkInterfaceModule = "e1000e";
  # From the Hetzner control panel
  ipv4 = {
    address = "95.216.13.236"; # the ip address
    gateway = "95.216.13.193"; # the gateway ip address
    netmask = "255.255.255.192"; # the netmask -- might not be the same for you!
    prefixLength = 26; # must match the netmask, see <https://www.pawprint.net/designresources/netmask-converter.php>
  };
  ipv6 = {
    address = "2a01:4f9:2a:e14::"; # the ipv6 addres
    gateway = "fe80::1"; # the ipv6 gateway
    prefixLength = 64; # shown in the control panel
  };
  # See <https://nixos.wiki/wiki/NixOS_on_ZFS> for why we need the
  # hostId and how to generate it
  hostId = "a020e02c";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/crafty.nix
      ../../modules/gokapi.nix
      ../../modules/tududi.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
  # We want to still be able to boot without one of these
  fileSystems."/boot-1".options = [ "nofail" ];
  fileSystems."/boot-2".options = [ "nofail" ];
  fileSystems."/boot-1".device = "/dev/disk/by-id/${sda}-part2";
  fileSystems."/boot-2".device = "/dev/disk/by-id/${sdb}-part2";

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };

  # This will mirror all UEFI files, kernels, grub menus and
  # things needed to boot to the other drive.
  boot.loader.grub.mirroredBoots = [
    { path = "/boot-1"; devices = [ "/dev/disk/by-id/${sda}" ]; }
    { path = "/boot-2"; devices = [ "/dev/disk/by-id/${sdb}" ]; }
  ];

  networking.hostName = hostName;

  # ZFS options from <https://nixos.wiki/wiki/NixOS_on_ZFS>
  networking.hostId = hostId;
  boot.loader.grub.copyKernels = true;
  boot.supportedFilesystems = [ "zfs" ];

  # Network configuration (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.interfaces.${networkInterface} = {
    ipv4 = { addresses = [{ address = ipv4.address; prefixLength = ipv4.prefixLength; }]; };
    ipv6 = { addresses = [{ address = ipv6.address; prefixLength = ipv6.prefixLength; }]; };
  };
  networking.defaultGateway = ipv4.gateway;
  networking.defaultGateway6 = { address = ipv6.gateway; interface = networkInterface; };
  networking.nameservers = [ "8.8.8.8" ];

  # Remote unlocking, see <https://nixos.wiki/wiki/NixOS_on_ZFS>,
  # section "Unlock encrypted zfs via ssh on boot"
  boot.initrd.availableKernelModules = [ networkInterfaceModule ];
  boot.kernelParams = [
    # See <https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt> for docs on this
    # ip=<client-ip>:<server-ip>:<gw-ip>:<netmask>:<hostname>:<device>:<autoconf>:<dns0-ip>:<dns1-ip>:<ntp0-ip>
    # The server ip refers to the NFS server -- we don't need it.
    "ip=${ipv4.address}::${ipv4.gateway}:${ipv4.netmask}:${hostName}-initrd:${networkInterface}:off:8.8.8.8"
  ];
  boot.initrd.network = {
    enable = true;
    ssh = {
       enable = true;
       # To prevent ssh clients from freaking out because a different host key is used,
       # a different port for ssh is useful (assuming the same host has also a regular sshd running)
       port = 2222;
       # hostKeys paths must be unquoted strings, otherwise you'll run into issues
       # with boot.initrd.secrets the keys are copied to initrd from the path specified;
       # multiple keys can be set you can generate any number of host keys using
       # `ssh-keygen -t ed25519 -N "" -f /boot-1/initrd-ssh-key`
       hostKeys = [
         /boot-1/initrd-ssh-key
         /boot-2/initrd-ssh-key
       ];
       # public ssh key used for login
       authorizedKeys = [ publicKey ];
    };
    # this will automatically load the zfs password prompt on login
    # and kill the other prompt so boot can continue
    postCommands = ''
      cat <<EOF > /root/.profile
      if pgrep -x "zfs" > /dev/null
      then
        zfs load-key -a
        killall zfs
      else
        echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
      fi
      EOF
    '';
  };

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # SSH
  users.users.root.openssh.authorizedKeys.keys = [ publicKey ];
  services.openssh.enable = true;
  programs.zsh.enable = true;
  environment.systemPackages = map lib.lowPrio [
    pkgs.gitMinimal
    pkgs.helix
  ];

  users.users.luisl = {
    isNormalUser = true;
    home = "/home/luisl";
    extraGroups  = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [    
      sshKeys."luisl@win".raw
      sshKeys."luisl@nixos-desktop".raw
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "luisl" = import ./home.nix;
    };
  };
  
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  # Temporary workaround, should IPv6 DNS be fixed in later release
  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_MAGIC_DNS_DUAL_STACK=true"
  ];

  services.nginx = {
    enable = true;
    recommendedBrotliSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    commonHttpConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';

    virtualHosts."jllamas.dev" = {
      enableACME = true;
      addSSL = true;
      globalRedirect = "xoltia.github.io";
    };

    virtualHosts."www.jllamas.dev" = {
      enableACME = true;
      addSSL = true;
      globalRedirect = "xoltia.github.io";
    };
    
    virtualHosts."gokapi.jllamas.dev" = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://127.0.0.1:53842";
      extraConfig = ''
        client_max_body_size 100M;
      '';
    };
  };

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/luisl/.config/sops/age/keys.txt";

  sops.secrets."copyparty/luisl_password".owner = "copyparty";

  nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

  services.copyparty = {
    enable = true;
    package = pkgs.copyparty-full;
    user = "copyparty"; 
    group = "copyparty"; 
    settings = {
      i = "0.0.0.0";
      sftp = "3922";
    };

    globalExtraConfig = ''
      sftp-key: luisl ${sshKeys."luisl@win".noComment}
      sftp-key: luisl ${sshKeys."luisl@nixos-desktop".noComment}
    '';

    accounts = {
      luisl = {
        passwordFile = config.sops.secrets."copyparty/luisl_password".path;
      };
    };

    volumes = {
      "/" = {
        path = "/srv/copyparty";
        access = {
          A = [ "luisl" ];
        };
        flags = {
          fk = 4;
          scan = 60;
          e2d = true;
          d2t = true;
        };
      };

      "/torrents" = {
        path = "/var/lib/qBittorrent/qBittorrent/downloads";
        access = {
          r = [ "luisl" ];
        };
        flags = {
          fk = 4;
          scan = 60;
          e2d = true;
          d2t = true;
        };
      };
    };
    openFilesLimit = 8192;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "llamas.jnl@gmail.com";
  };

  sops.secrets.mullvad_config = { };

  services.qbittorrent = {
    enable = true;
    webuiPort = 8080;
    openFirewall = false;
  };

  systemd.services.qbittorrent.vpnConfinement = {
    enable = true;
    vpnNamespace = "mullvad";
  };

  vpnNamespaces.mullvad = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.mullvad_config.path;
    # Allow access from Tailscale network
    accessibleFrom = [ "100.64.0.0/10" ];
    portMappings = [
      { from = 8080; to = 8080; protocol = "tcp"; }
    ];
    # Mullvad doesn't support port forwarding
    openVPNPorts = [];
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}

