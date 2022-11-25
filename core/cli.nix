{ config, pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [
      aumix
      file
      git
      htop
      irssi
      lm_sensors
      man-pages
      neovim
      openssh
      powerline-go
      python38
      speedtest-cli
      testdisk
      tmux
      tree
    ];
  };

  # android debug bridge
  programs.adb.enable = true;

  # admin settings
  security.sudo.wheelNeedsPassword = false;

  networking.enableIPv6 = false;

}
