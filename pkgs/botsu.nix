{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "0.3.4-dev.0fc9fbc";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu";
    rev = "0fc9fbc62d5093ca004f6d218e79e060ef9368ec";
    hash = "sha256-ceTqEbO6h/8NTNvW9Fne7QoK4ifGCp2/hi5eWIBigtI=";
  };
  subPackages = ["cmd/botsu"];
  vendorHash = "sha256-VZcR86ylVHI2jt4VdgvM8VA4iJtA6OM9ZhHF3tuG/vs=";
}
