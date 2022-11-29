{ config, pkgs, lib, ... }:

let
  # international hotkeys
  customKeymap = pkgs.writeText "xkb-layout" ''
    ! Map umlauts to RIGHT ALT + <key>
    keycode 108 = Mode_switch
    keysym e = e E EuroSign
    keysym c = c C cent
    keysym a = a A adiaeresis Adiaeresis
    keysym o = o O odiaeresis Odiaeresis
    keysym u = u U udiaeresis Udiaeresis
    keysym s = s S ssharp
  '';
in with lib; {
  services = {
    # enable the X11 windowing syste
    xserver = {
      enable = true;
      xkbOptions = "eurosign:e";
      desktopManager.xterm.enable = false;
      displayManager = {
        defaultSession = "gnome-xorg";
        gdm.enable = true;
        sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${customKeymap}";
      };
    };
  };
}
