{ config, pkgs, lib, ... }:

{
    services.xserver.desktopManager.plasma5.enable = true;
    programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.plasma5.ksshaskpass.out}/bin/ksshaskpass";
}