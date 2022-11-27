{ config, pkgs, lib, ... }:

with lib; {
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [ gparted simple-scan xclip lsof ];
  };
}
