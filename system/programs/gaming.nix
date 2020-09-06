{ config, pkgs, lib, ... }:

let
  minecraft-override =
    pkgs.minecraft.overrideAttrs (oldAttrs: { version = "2.1.13509"; });
in with lib; {
  config = mkIf (config.desk != "none") {
    environment = {
      # add some desktop applications
      systemPackages = with pkgs; [ minecraft-override steam ];
    };
    hardware.opengl.driSupport32Bit = true;
    hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    hardware.pulseaudio.support32Bit = true;
  };
}
