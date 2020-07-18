{ config, pkgs, ... }:

{
  services.xserver.windowManager = {
    default = "xmonad";
    xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
  };
}
