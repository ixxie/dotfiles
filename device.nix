{inputs, ...}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
  ];
  services.fwupd.enable = true; # firmware
  services.upower.enable = true; # battery monitoring
  services.power-profiles-daemon.enable = true; # battery
  hardware.bluetooth.enable = true;
  boot.initrd.kernelModules = ["amdgpu"]; # graphics
  boot.kernelParams = ["amdgpu.aspm=0"]; # fix spurious PME interrupts on Phoenix
  services.fprintd.enable = false;
  hardware = {
    # disable framework kernel module
    # https://github.com/NixOS/nixos-hardware/issues/1330
    framework.enableKmod = false;
    amdgpu.initrd.enable = true;
  };
}
