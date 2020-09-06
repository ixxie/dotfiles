{ config, pkgs, lib, ... }:

with lib; {
  options = {
    # make an option to enable or desable the desktop environment
    desk = mkOption {
      type = types.str;
      default = "none";
      description = "Sets the desktop environment; set to: none or gnome.";
    };
  };
}
