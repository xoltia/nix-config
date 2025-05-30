{ pkgs, ... }:

with pkgs; buildGoModule {
  pname = "botsu";
  version = "0.3.4-dev.4263a2c";
  src = fetchFromGitHub {
    owner = "xoltia";
    repo = "botsu";
    rev = "4263a2cad704ce7f46e813054b662339f71c1b94";
    hash = "sha256-N9/5vYuPY9is7prGZMDymtxD9J98jBHRWHAPa23EuyI=";
  };
  subPackages = ["cmd/botsu"];
  vendorHash = "sha256-VZcR86ylVHI2jt4VdgvM8VA4iJtA6OM9ZhHF3tuG/vs=";
}
