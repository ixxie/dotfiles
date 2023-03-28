{ config, pkgs, ... }:

{
  # Use the gummiboot efi boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # enable the swap device
  swapDevices = [{ label = "swap"; }];

  # firmware support
  nixpkgs.config.allowUnfree = true;

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth = {
      enable = true;
      settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
    };

  };

  # fix various kinks
  services.xserver = {
    # Make right click
    libinput = {
      enable = true;
      mouse.buttonMapping = "1 2 3 4 5 6";
      touchpad = {
        middleEmulation = false;
        tappingButtonMap = "lrm";
      };
    };
  };
  boot = {
    blacklistedKernelModules = [
      "mei_wdt" # for udev wait for device
    ];
    supportedFilesystems = [ "ntfs-3g" ];
  };
}
