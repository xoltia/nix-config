{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, ... }@inputs: {
      nixosConfigurations.nixos-desktop = nixpkgs.lib.nixosSystem rec {
        specialArgs = let
          system = "x86_64-linux";
        in {
          inherit inputs;
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./hosts/nixos-desktop
          inputs.home-manager.nixosModules.default
          {
            home-manager.extraSpecialArgs = {
              pkgs-stable = specialArgs.pkgs-stable;
            };
          }
        ];
      };
      
      nixosConfigurations.nixos-hetzner-dedicated = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-hetzner-dedicated
          inputs.sops-nix.nixosModules.default
          inputs.home-manager.nixosModules.default
          inputs.copyparty.nixosModules.default
          inputs.vpn-confinement.nixosModules.default
        ];
      };

      nixosConfigurations.nixos-hetzner-vps = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-hetzner-vps
          inputs.disko.nixosModules.default
          inputs.home-manager.nixosModules.default
          inputs.sops-nix.nixosModules.default
        ];
      };

      nixosConfigurations.nixos-wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos-wsl
          inputs.home-manager.nixosModules.default
          inputs.nixos-wsl.nixosModules.default
          inputs.sops-nix.nixosModules.default
        ];
      };
  };
}
