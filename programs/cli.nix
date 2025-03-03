{ pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [
      file
      git
      gnumake
      htop
      lm_sensors
      man-pages
      ngrok
      openssh
      testdisk
      tree
      lshw
      ripgrep
      alacritty-theme
      # shell
      starship
      nushellPlugins.query
      # completers
      carapace
      zoxide
      fish
    ];
  };

  # android debug bridge
  programs.adb.enable = true;

  # admin settings
  security.sudo.wheelNeedsPassword = false;

  networking.enableIPv6 = false;
}
