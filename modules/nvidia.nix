{ config, lib, pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  # Maybe fixes occasional freezing.
  # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/739
  # Also maybe fix suspend failing...
  # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472#issuecomment-2762633335
  boot.extraModprobeConfig = ''
    options nvidia NVreg_EnableGpuFirmware=0
    options nvidia NVreg_EnableS0ixPowerManagement=0
  '';

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}

