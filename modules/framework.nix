{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];
  services.fwupd.enable = true; # firmware
  services.power-profiles-daemon.enable = true; # battery
  boot.initrd.kernelModules = [ "amdgpu" ]; # graphics
  services.fprintd.enable = false;
  hardware = {
    # disable framework kernel module
    # https://github.com/NixOS/nixos-hardware/issues/1330
    framework.enableKmod = false;
  };
}
