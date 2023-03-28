{ config, pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [
      file
      git
      gnumake
      htop
      irssi
      lm_sensors
      man-pages
      neovim
      ngrok
      openssh
      testdisk
      tmux
      tree
      lshw
      starship
    ];
  };

  # android debug bridge
  programs.adb.enable = true;

  # admin settings
  security.sudo.wheelNeedsPassword = false;

  networking.enableIPv6 = false;
}
