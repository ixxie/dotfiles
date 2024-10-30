{ ... }:

{
  services.fwupd.enable = true; # firmware
  services.power-profiles-daemon.enable = true; # battery
  boot.initrd.kernelModules = [ "amdgpu" ]; # graphics
}
