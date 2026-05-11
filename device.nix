{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.framework-13-7040-amd
    inputs.zapp.nixosModules.default
  ];
  programs.zapp.enable = true;
  services.fwupd.enable = true; # firmware
  services.upower.enable = true; # battery monitoring
  services.power-profiles-daemon.enable = true; # battery
  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };
  boot.initrd.kernelModules = ["amdgpu"]; # graphics
  boot.kernelParams = ["amdgpu.aspm=0"]; # fix spurious PME interrupts on Phoenix
  services.fprintd.enable = false;
  hardware = {
    # disable framework kernel module
    # https://github.com/NixOS/nixos-hardware/issues/1330
    framework.enableKmod = false;
    amdgpu.initrd.enable = true;
    # zsa voyager
    keyboard.zsa.enable = true;
  };
  environment.systemPackages = with pkgs; [keymapp];
}
