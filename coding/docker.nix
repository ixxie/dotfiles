{ config, pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [
      docker
      docker-compose
    ];
  };

  virtualisation.docker.enable = true;
}
