{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
        python39Packages.autopep8
    ];
  };
}