# Nix Config

This is the repository for my NixOS configuration. I currently use it to configure three different hosts:
- `nixos-desktop`: Primary Desktop
- `nixos-hetzner-vps`: Hetzner ARM VPS
- `nixos-wsl`: Windows WSL2 NixOS

The general structure is as follows:
- `modules`: NixOS modules for setting configuration and custom services
- `hm-modules`: Home Manager modules loosely split by use case (e.g. `zsh.nix` configures prompt, fzf, etc.)
- `pkgs`: Custom software packages
- `secrets`: Secrets using sops-nix
- `hosts`: Different host configurations
