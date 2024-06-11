{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = let system = "x86_64-linux"; in {
        inherit inputs;
        inherit system;
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config = { allowUnfree = true; };  
        };
      };
      modules = [
        ./hosts/desktop
        ./configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };

    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      specialArgs = let system = "x86_64-linux"; in {
        inherit inputs;
        inherit system;
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config = { allowUnfree = true; };  
        };
      };
      modules = [
        ./hosts/laptop
        ./configuration.nix
        inputs.home-manager.nixosModules.default
      ];
    };
  };
}
