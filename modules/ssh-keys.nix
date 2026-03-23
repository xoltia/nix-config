{ lib, ... }:
let
  parseKey = keyString:
    let
      parts = lib.splitString " " keyString;
      type = builtins.elemAt parts 0;
      publicKey = builtins.elemAt parts 1;
      comment = lib.concatStringsSep " " (lib.drop 2 parts);
    in
    {
      name = comment;
      value = {
        inherit type publicKey comment;
        noComment = "${type} ${publicKey}";
        raw = keyString;
      };
    };
  parseKeys = keys:
    builtins.listToAttrs (map parseKey keys);
in
parseKeys [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMuHkhyxPAtN+Ug4b2HPUDjMyPcKCyQuQUmJdyH4g9ta luisl@fedora"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmGpQOWf+QALQmDHy9ORasGR5AB15FMD2DcKd29EZvc luisl@win"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN4lxvIxjiF2WwXKeayBDjzLNBsB3mQ2hOS5d519ysbo luisl@nixos-desktop"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVzRgt7toWfPAEAFFN4a4XK8L0IXraTx4C2u3J9f3yO luisl@nixos-hetzner-vps"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEzk3lPhMjqFh23XReBtVy5lIdXj6js8NSLYvpLIkPIe nixos@nixos-wsl"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrryFSxYCamdYRQreQiFPJ2pdYIWdhq4ufYpc6mWErE luisl@win:initrd"
]
