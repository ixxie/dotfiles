{ config, pkgs, ... }:

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
    keysym Super_L = keycode 133
  '';
in {
  services = {
    xserver = {
      enable = true;
      xkbOptions = "eurosign:e";
      displayManager = {
        lightdm = { enable = true; };
        sessionCommands = "${pkgs.xorg.xmodmap}/bin/xmodmap ${customKeymap}";
      };
      desktopManager.gnome = { enable = true; };
    };
    gnome.core-utilities.enable = false;
    illum.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      numix-gtk-theme
      numix-icon-theme-circle
      arc-icon-theme
      arc-theme
      gnomeExtensions.paperwm
      gnomeExtensions.dash-to-panel
      gnomeExtensions.switcher
      gnome.gnome-tweaks
      gnome.nautilus
    ];

    # GTK3 global theme (widget and icon theme)
    etc."xdg/gtk-3.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-icon-theme-name=Arc
        gtk-theme-name=Arc-dark
        gtk-application-prefer-dark-theme = true
      '';
    };
  };
}
