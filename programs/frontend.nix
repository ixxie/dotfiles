{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ nodejs_22 ];
  };
}
