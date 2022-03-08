{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    intel-media-driver
  ];

}
